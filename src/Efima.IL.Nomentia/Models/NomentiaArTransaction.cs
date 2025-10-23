using System;
using System.Collections.Generic;
using System.Xml.Serialization;

namespace Efima.Integration.Nomentia.Models;

[Serializable, XmlType(AnonymousType = true), XmlRoot(ElementName = "Transaction", Namespace = "", IsNullable = false)]
public class NomentiaArTransaction
{
    public NomentiaArTransaction()
    {
        EntryAmount = new NomentiaArTransactionAmount();
        RemainingAmount = new NomentiaArTransactionAmount();
        CustomFields = new List<NomentiaArTransactionCustomField>();
    }
    [XmlAttribute]
    public string status;

    public string UniqueId;
    public string OrganisationIdentification;
    public string DueDate;
    public string InvoiceDate;
    public string DebtorName;
    public string DebtorIdentification;
    public string DebtorPostalAddress;
    public NomentiaArTransactionAmount EntryAmount;
    public NomentiaArTransactionAmount RemainingAmount;
    public string CreditDebitIndicator;
    public string ReferenceNumber;
    public string InvoiceNumber;
    [XmlElement(ElementName = "CustomField")]
    public List<NomentiaArTransactionCustomField> CustomFields;
}
public class NomentiaArTransactionAmount
{
    [XmlText]
    public string value;
    [XmlAttribute]
    public string Ccy;
}
public class NomentiaArTransactionCustomField
{
    [XmlText]
    public string value;
    [XmlAttribute]
    public string name;
}