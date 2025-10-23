using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using Efima.Core.Shared.Values;
using Efima.IL;
using Efima.IL.Model;
using Efima.IL.Utils;
using Efima.Integration.Nomentia.Models;
using Efima.Integration.Nomentia.Values;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

namespace Efima.Integration.Nomentia.Services;

internal class BankStatementTransformService : IDataTransformService<Base64FileTransformRequest, ExpenseJournalLineWithHeaderEntityResponse>
{
	private readonly IValuesService valuesService;

	private class DimensionData
	{
		public string AccountDisplayValue;
		public string SalesTaxGroup;
		public string ItemSalesTaxGroup;
	}

	public BankStatementTransformService(IValuesService valuesService)
	{
		this.valuesService = valuesService;
	}

	public async Task<ExpenseJournalLineWithHeaderEntityResponse> Transform(Base64FileTransformRequest requestBodyJson)
	{
		var bankStatementXmlBytes = Convert.FromBase64String(requestBodyJson.ContentBase64);
		var xmlDocument = new XmlDocument();
		xmlDocument.Load(new MemoryStream(bankStatementXmlBytes));

		var transactions = XmlUtils.Deserialize<OpusCapitaAccountsTransactions>(xmlDocument.OuterXml, true);

		// Read setting values.
		var partitionKeys = NomentiaBankStatementValues.Instance.GetPartitionKeys();
		string journalName = valuesService.GetDefaultValue<string>("JournalName", partitionKeys);
		string accountType = valuesService.GetDefaultValue<string>("AccountType", partitionKeys);
		string accountDisplayValueFormat = valuesService.GetDefaultValue<string>("AccountDisplayValueFormat", partitionKeys);
		string taxGroupDimensionName = valuesService.GetDefaultValue<string>("TaxGroupDimensionName", partitionKeys);
		valuesService.TryGetDefaultValue<string>("SkipRow", partitionKeys, out string skipRow); // Optional

		var entities = new Collection<EfiExpenseJournalLineWithHeaderEntity>();
		var lineNumber = 1;
		var efiHeaderLinkId = Guid.NewGuid();
		foreach (OpusCapitaAccountsTransactionsTransaction transaction in transactions.Transaction)
		{
			foreach (var postingRow in transaction.PostingHeader.PostingRow)
			{
				DimensionData dimensionData = GetDimensionData(postingRow.Dimension,
					accountDisplayValueFormat, taxGroupDimensionName, skipRow);
				if (dimensionData == null)
					continue;

				bool isCredit = postingRow.Amount < 0;
				var entity = new EfiExpenseJournalLineWithHeaderEntity
				{
					AccountDisplayValue = dimensionData.AccountDisplayValue,
					AccountType = accountType,
					CurrencyCode = transaction.PostingHeader.Currency,
					CreditAmount = isCredit ? Math.Abs(postingRow.Amount) : 0,
					DebitAmount = isCredit ? 0 : postingRow.Amount,
					Description = transaction.Voucher.DocumentTypeDescription,
					// Added support for CompanyCode mapping. Will not care if not found in 365, but let error come from there.
					EfiCompanyContext = valuesService.TryGetConversionValue<string>("CompanyCode", transaction.Company.Code,
						NomentiaBankStatementValues.Instance.GetPartitionKeys(), out string mappedCompany) ?
							mappedCompany : transaction.Company.Code,
					EfiHeaderLinkId = efiHeaderLinkId,
					ItemSalesTaxGroup = dimensionData.ItemSalesTaxGroup ?? string.Empty,
					JournalName = journalName,
					SalesTaxGroup = dimensionData.SalesTaxGroup ?? string.Empty,
					Text = postingRow.Description,
					Voucher = transaction.Voucher.Number,
					VoucherDate = transaction.Voucher.Date,
					LineNumber = lineNumber++
				};
				entities.Add(entity);
			}
		}

		return new ExpenseJournalLineWithHeaderEntityResponse(entities);
	}

	private DimensionData GetDimensionData(OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRowDimension[] dimensions,
										   string accountDisplayValueFormat,
										   string taxGroupName,
										   string skipRows)
	{
		// Check if this row should be skipped. SkipRows is of the format 'name=value1;value2;value3;...'
		// where 'name' refers to a dimension name attribute and 'valueX' to its value.
		string value;
		string[] splitted;
		if (!string.IsNullOrEmpty(skipRows))
		{
			splitted = skipRows.Split('=');
			if (splitted.Length == 2)
			{
				value = dimensions.FirstOrDefault(x => x.Name == splitted[0])?.Value;
				if (!String.IsNullOrEmpty(value) && splitted[1].Split(';').Contains(value))
				{
					return null;
				}
			}
			else
			{
				throw new FormatException("Table value 'SkipRows' has invalid format.");
			}
		}

		// AccountDisplayValueFormat is of the format '{name1}-{name2}-{name3}-...' where
		// 'nameX' refers to a dimension name attribute. The saparator can be any character.
		// The following, however, allows the separator to be any string!
		string adv = accountDisplayValueFormat;
		splitted = adv.Split(['{', '}']);
		for (int i = 1; i < splitted.Length; i += 2)
		{
			string name = splitted[i];
			value = dimensions.FirstOrDefault(x => x.Name == name)?.Value;
			adv = adv.Replace("{" + name + "}", value);
		}

		// Find tax-group and map to SalesTaxGroup & ItemSalesTaxGroup (in case a mapping is found).
		value = dimensions.FirstOrDefault(x => x.Name == taxGroupName)?.Value;
		string salesTaxGroup = null, itemSalesTaxGroup = null;
		if (!String.IsNullOrWhiteSpace(value))
		{
			salesTaxGroup = valuesService.TryGetConversionValue<string>("SalesTaxGroup", value,
				NomentiaBankStatementValues.Instance.GetPartitionKeys(), out string help) ?
					help : value;
			itemSalesTaxGroup = valuesService.TryGetConversionValue<string>("ItemSalesTaxGroup", value,
				NomentiaBankStatementValues.Instance.GetPartitionKeys(), out string help2) ?
					help2 : value;
		}

		return new DimensionData
		{
			AccountDisplayValue = adv,
			SalesTaxGroup = salesTaxGroup,
			ItemSalesTaxGroup = itemSalesTaxGroup
		};
	}
}
