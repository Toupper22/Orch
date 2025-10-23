using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using Efima.Core.Shared.Values;
using Efima.IL;
using Efima.IL.Model;
using Efima.IL.Utils;
using Efima.Integration.Nomentia.Models;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Efima.Integration.Nomentia.Services;

public class D365ArTransactionsTransformService
    : IDataTransformService<Base64FileTransformRequest, Base64FileResponse>
{
    private readonly IValuesService valuesService;
    private readonly ILogger<D365ArTransactionsTransformService> logger;

    public D365ArTransactionsTransformService(
        IValuesService valuesService,
        ILogger<D365ArTransactionsTransformService> logger
    )
    {
        this.valuesService = valuesService;
        this.logger = logger;
    }

    public async Task<Base64FileResponse> Transform(Base64FileTransformRequest requestBodyJson)
    {
        if (string.IsNullOrEmpty(requestBodyJson.ContentBase64))
        {
            return new Base64FileResponse { ContentBase64 = string.Empty };
        }

        var packageBytes = Convert.FromBase64String(requestBodyJson.ContentBase64);
        using var packageStream = new MemoryStream(packageBytes);
        var zipArchive = new ZipArchive(packageStream);

        string resultXml = null;
        foreach (var entry in zipArchive.Entries)
        {
            resultXml = await HandlePackageEntryAsync(entry);
            if (!string.IsNullOrEmpty(resultXml))
            {
                break;
            }
        }
        if (string.IsNullOrEmpty(resultXml))
        {
            return new Base64FileResponse { ContentBase64 = string.Empty };
        }

        return new Base64FileResponse
		{
			ContentBase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(resultXml)),
            Filename = requestBodyJson.Filename
		};
    }

    protected async Task<string> HandlePackageEntryAsync(ZipArchiveEntry entry)
    {
        if (!entry.Name.Equals("Efima - Customer Transactions.xml"))
        {
            return null;
        }

        logger.LogInformation($"Transforming file {entry.Name}");
        await using var xmlStream = entry.Open();

        var xmlDocument = new XmlDocument();
        xmlDocument.Load(xmlStream);

        if (xmlDocument.DocumentElement == null ||
            xmlDocument.DocumentElement.ChildNodes == null ||
            xmlDocument.DocumentElement.ChildNodes.Count == 0)
        {
            logger.LogWarning($"No records found in file {entry.Name}");
            return null;
        }

        var transactionList = new List<NomentiaArTransaction>();
        foreach (XmlNode entityNode in xmlDocument.DocumentElement.ChildNodes)
        {
            //var entity = XmlUtils.Deserialize<DocumentEFIPRINTLEDGERTRANSCUSTENTITY>(entityNode.OuterXml);
            // this doesn't work, because of possible empty records, and also CDATA sections
            var entityXElement = XElement.Parse(entityNode.OuterXml);
            var cdata = entityXElement.DescendantNodes().OfType<XCData>().ToList();
            foreach (var cd in cdata)
            {
                cd.Parent.Add(cd.Value);
                cd.Remove();
            }
            var entityNodeJson = JsonConvert.SerializeXNode(entityXElement, Newtonsoft.Json.Formatting.None, omitRootObject: true);
            var entityNodeDoc = new XmlDocument();
            entityNodeDoc.LoadXml(entityNode.OuterXml);
            var entity = JsonConvert.DeserializeObject<DocumentEFIPRINTLEDGERTRANSCUSTENTITY>(entityNodeJson);

            if (entity.RECID1 == 0)
            {
                // empty record
                continue;
            }

            if (entity.TRANSTYPE != "Cust" && entity.TRANSTYPE != "GeneralJournal")
            {
                // only these types of transactions allowed
                continue;
            }

            var transaction = new NomentiaArTransaction
            {
                UniqueId = entity.RECID1.ToString()
            };
            if (entity.CLOSED > new DateTime(1900, 1, 1, 0, 0, 0))
            {
                transaction.status = "removed";
            }
            else
            {
                transaction.InvoiceDate = entity.TRANSDATE.ToString("yyyy-MM-dd");
                transaction.InvoiceNumber = entity.INVOICE;
                transaction.EntryAmount.value = entity.AMOUNTCUR.ToString("0.00");
                transaction.EntryAmount.Ccy = entity.CURRENCYCODE;
                transaction.DebtorIdentification = entity.CUSTACCOUNTNUM;
                transaction.DebtorName = entity.CUSTOMERNAME;
                transaction.OrganisationIdentification = entity.DATAAREAID1;
                transaction.DueDate = entity.DUEDATE.ToString("yyyy-MM-dd");
                transaction.CreditDebitIndicator = entity.AMOUNTCUR >= 0 ? "DBIT" : "CRDT";
                transaction.ReferenceNumber = entity.PAYMREFERENCE;
                transaction.RemainingAmount.value = (entity.AMOUNTCUR - entity.SETTLEAMOUNTCUR).ToString("0.00");
                transaction.RemainingAmount.Ccy = entity.CURRENCYCODE;
                if (!string.IsNullOrEmpty(entity.TXT))
                {
                    transaction.CustomFields.Add(new NomentiaArTransactionCustomField { name = "CarID", value = entity.TXT });
                }
            }

            transactionList.Add(transaction);
        }

        if (transactionList.Count == 0)
        {
            logger.LogWarning($"No records found in file {entry.Name}");
            return null;
        }

        var resultXmlDocument = new XmlDocument();
        resultXmlDocument.InsertBefore(resultXmlDocument.CreateXmlDeclaration("1.0", "UTF-8", null),
            resultXmlDocument.DocumentElement);
        var matchingElement = resultXmlDocument.CreateElement(string.Empty, "Matching", string.Empty);
        resultXmlDocument.AppendChild(matchingElement);

        foreach (var transaction in transactionList)
        {
            var transactionNode = (XmlElement)matchingElement.OwnerDocument.ImportNode(
                XmlUtils.SerializeToXmlElement(transaction), true);
            transactionNode.RemoveAttribute("xmlns:xsi");
            transactionNode.RemoveAttribute("xmlns:xsd");
            matchingElement.AppendChild(transactionNode);
        }

        return resultXmlDocument.OuterXml;
    }
}