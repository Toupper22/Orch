using System;
using System.ComponentModel;
using System.Xml.Serialization;

namespace Efima.Integration.Nomentia.Models;

// NOTE: Generated code may require at least .NET Framework 4.5 or .NET Core/Standard 2.0.
/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions"),
 XmlRoot(Namespace = "urn:schemas-opuscapita-com:accounts:transactions",
     IsNullable = false)]
public partial class OpusCapitaAccountsTransactions
{

    private OpusCapitaAccountsTransactionsParameters parametersField;

    private OpusCapitaAccountsTransactionsTransaction[] transactionField;

    private string versionField;

    private DateTime createdOnField;

    private string createdByField;

    /// <remarks/>
    public OpusCapitaAccountsTransactionsParameters Parameters
    {
        get
        {
            return parametersField;
        }
        set
        {
            parametersField = value;
        }
    }

    /// <remarks/>
    [XmlElement("Transaction")]
    public OpusCapitaAccountsTransactionsTransaction[] Transaction
    {
        get
        {
            return transactionField;
        }
        set
        {
            transactionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Version
    {
        get
        {
            return versionField;
        }
        set
        {
            versionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime CreatedOn
    {
        get
        {
            return createdOnField;
        }
        set
        {
            createdOnField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CreatedBy
    {
        get
        {
            return createdByField;
        }
        set
        {
            createdByField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsParameters
{

    private DateTime entryDateStartField;

    private DateTime entryDateEndField;

    private bool requirePostedField;

    private bool requireVoucherNoField;

    private bool includePreviouslyRunField;

    /// <remarks/>
    [XmlAttribute]
    public DateTime EntryDateStart
    {
        get
        {
            return entryDateStartField;
        }
        set
        {
            entryDateStartField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime EntryDateEnd
    {
        get
        {
            return entryDateEndField;
        }
        set
        {
            entryDateEndField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public bool RequirePosted
    {
        get
        {
            return requirePostedField;
        }
        set
        {
            requirePostedField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public bool RequireVoucherNo
    {
        get
        {
            return requireVoucherNoField;
        }
        set
        {
            requireVoucherNoField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public bool IncludePreviouslyRun
    {
        get
        {
            return includePreviouslyRunField;
        }
        set
        {
            includePreviouslyRunField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransaction
{

    private OpusCapitaAccountsTransactionsTransactionStatement statementField;

    private OpusCapitaAccountsTransactionsTransactionAccount accountField;

    private OpusCapitaAccountsTransactionsTransactionCompany companyField;

    private OpusCapitaAccountsTransactionsTransactionTransactionDetails transactionDetailsField;

    private OpusCapitaAccountsTransactionsTransactionStatus[] statusField;

    private OpusCapitaAccountsTransactionsTransactionPostingHeader postingHeaderField;

    private OpusCapitaAccountsTransactionsTransactionVoucher voucherField;

    private string idField;

    private string parentIdField;

    private string accountingCurrencyField;

    private decimal amountField;

    private decimal amountInAccountingCurrencyField;

    private string creditorField;

    private string creditorOriginField;

    private string currencyField;

    private string entryCodeField;

    private string entryCodeDomainField;

    private string entryCodeFamilyField;

    private string entryCodeSubFamilyField;

    private DateTime entryDateField;

    private string entryDefinitionCodeField;

    private string entryDefinitionTextField;

    private decimal exchangeRateField;

    private bool isExchangeRateIndirectField;

    private DateTime exchangeRateDateField;

    private bool isManuallySetExchangeRateField;

    private string formNumberField;

    private string legalSequenceNumberField;

    private string materialCodeField;

    private string materialTypeField;

    private string modifiedReferenceField;

    private DateTime paymentDateField;

    private string recordCodeField;

    private string resplitStatusField;

    private string transactionNumberField;

    private string transactionTypeField;

    private string transmissionFacilityField;

    private DateTime valueDateField;

    private string liquidityCashFlowGroupField;

    private DateTime modifiedOnField;

    private string modifiedByField;

    private DateTime endingDateField;

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionStatement Statement
    {
        get
        {
            return statementField;
        }
        set
        {
            statementField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionAccount Account
    {
        get
        {
            return accountField;
        }
        set
        {
            accountField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionCompany Company
    {
        get
        {
            return companyField;
        }
        set
        {
            companyField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionTransactionDetails TransactionDetails
    {
        get
        {
            return transactionDetailsField;
        }
        set
        {
            transactionDetailsField = value;
        }
    }

    /// <remarks/>
    [XmlElement("Status")]
    public OpusCapitaAccountsTransactionsTransactionStatus[] Status
    {
        get
        {
            return statusField;
        }
        set
        {
            statusField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionPostingHeader PostingHeader
    {
        get
        {
            return postingHeaderField;
        }
        set
        {
            postingHeaderField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionVoucher Voucher
    {
        get
        {
            return voucherField;
        }
        set
        {
            voucherField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ParentId
    {
        get
        {
            return parentIdField;
        }
        set
        {
            parentIdField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AccountingCurrency
    {
        get
        {
            return accountingCurrencyField;
        }
        set
        {
            accountingCurrencyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal Amount
    {
        get
        {
            return amountField;
        }
        set
        {
            amountField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal AmountInAccountingCurrency
    {
        get
        {
            return amountInAccountingCurrencyField;
        }
        set
        {
            amountInAccountingCurrencyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Creditor
    {
        get
        {
            return creditorField;
        }
        set
        {
            creditorField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CreditorOrigin
    {
        get
        {
            return creditorOriginField;
        }
        set
        {
            creditorOriginField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Currency
    {
        get
        {
            return currencyField;
        }
        set
        {
            currencyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string EntryCode
    {
        get
        {
            return entryCodeField;
        }
        set
        {
            entryCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string EntryCodeDomain
    {
        get
        {
            return entryCodeDomainField;
        }
        set
        {
            entryCodeDomainField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string EntryCodeFamily
    {
        get
        {
            return entryCodeFamilyField;
        }
        set
        {
            entryCodeFamilyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string EntryCodeSubFamily
    {
        get
        {
            return entryCodeSubFamilyField;
        }
        set
        {
            entryCodeSubFamilyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime EntryDate
    {
        get
        {
            return entryDateField;
        }
        set
        {
            entryDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string EntryDefinitionCode
    {
        get
        {
            return entryDefinitionCodeField;
        }
        set
        {
            entryDefinitionCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string EntryDefinitionText
    {
        get
        {
            return entryDefinitionTextField;
        }
        set
        {
            entryDefinitionTextField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal ExchangeRate
    {
        get
        {
            return exchangeRateField;
        }
        set
        {
            exchangeRateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public bool IsExchangeRateIndirect
    {
        get
        {
            return isExchangeRateIndirectField;
        }
        set
        {
            isExchangeRateIndirectField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime ExchangeRateDate
    {
        get
        {
            return exchangeRateDateField;
        }
        set
        {
            exchangeRateDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public bool IsManuallySetExchangeRate
    {
        get
        {
            return isManuallySetExchangeRateField;
        }
        set
        {
            isManuallySetExchangeRateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string FormNumber
    {
        get
        {
            return formNumberField;
        }
        set
        {
            formNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string LegalSequenceNumber
    {
        get
        {
            return legalSequenceNumberField;
        }
        set
        {
            legalSequenceNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string MaterialCode
    {
        get
        {
            return materialCodeField;
        }
        set
        {
            materialCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string MaterialType
    {
        get
        {
            return materialTypeField;
        }
        set
        {
            materialTypeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ModifiedReference
    {
        get
        {
            return modifiedReferenceField;
        }
        set
        {
            modifiedReferenceField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime PaymentDate
    {
        get
        {
            return paymentDateField;
        }
        set
        {
            paymentDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RecordCode
    {
        get
        {
            return recordCodeField;
        }
        set
        {
            recordCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ResplitStatus
    {
        get
        {
            return resplitStatusField;
        }
        set
        {
            resplitStatusField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string TransactionNumber
    {
        get
        {
            return transactionNumberField;
        }
        set
        {
            transactionNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string TransactionType
    {
        get
        {
            return transactionTypeField;
        }
        set
        {
            transactionTypeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string TransmissionFacility
    {
        get
        {
            return transmissionFacilityField;
        }
        set
        {
            transmissionFacilityField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime ValueDate
    {
        get
        {
            return valueDateField;
        }
        set
        {
            valueDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string LiquidityCashFlowGroup
    {
        get
        {
            return liquidityCashFlowGroupField;
        }
        set
        {
            liquidityCashFlowGroupField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime ModifiedOn
    {
        get
        {
            return modifiedOnField;
        }
        set
        {
            modifiedOnField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ModifiedBy
    {
        get
        {
            return modifiedByField;
        }
        set
        {
            modifiedByField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime EndingDate
    {
        get
        {
            return endingDateField;
        }
        set
        {
            endingDateField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionStatement
{

    private OpusCapitaAccountsTransactionsTransactionStatementStatus[] statusField;

    private string idField;

    private string numberField;

    private DateTime startDateField;

    private DateTime endDateField;

    /// <remarks/>
    [XmlElement("Status")]
    public OpusCapitaAccountsTransactionsTransactionStatementStatus[] Status
    {
        get
        {
            return statusField;
        }
        set
        {
            statusField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Number
    {
        get
        {
            return numberField;
        }
        set
        {
            numberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime StartDate
    {
        get
        {
            return startDateField;
        }
        set
        {
            startDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime EndDate
    {
        get
        {
            return endDateField;
        }
        set
        {
            endDateField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionStatementStatus
{

    private string idField;

    private string codeField;

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Code
    {
        get
        {
            return codeField;
        }
        set
        {
            codeField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionAccount
{

    private string nameField;

    private string numberField;

    private string bankNameField;

    private string bICField;

    private string accountHolderField;

    /// <remarks/>
    [XmlAttribute]
    public string Name
    {
        get
        {
            return nameField;
        }
        set
        {
            nameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Number
    {
        get
        {
            return numberField;
        }
        set
        {
            numberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BankName
    {
        get
        {
            return bankNameField;
        }
        set
        {
            bankNameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BIC
    {
        get
        {
            return bICField;
        }
        set
        {
            bICField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AccountHolder
    {
        get
        {
            return accountHolderField;
        }
        set
        {
            accountHolderField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionCompany
{

    private string codeField;

    private string nameField;

    /// <remarks/>
    [XmlAttribute]
    public string Code
    {
        get
        {
            return codeField;
        }
        set
        {
            codeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Name
    {
        get
        {
            return nameField;
        }
        set
        {
            nameField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionTransactionDetails
{

    private OpusCapitaAccountsTransactionsTransactionTransactionDetailsPayeeAccount payeeAccountField;

    private OpusCapitaAccountsTransactionsTransactionTransactionDetailsCreditorAccount creditorAccountField;

    private OpusCapitaAccountsTransactionsTransactionTransactionDetailsDebtorAccount debtorAccountField;

    private string filingCodeField;

    private string customerNumberField;

    private string invoiceNumberField;

    private string cardNumberField;

    private string filingReferenceField;

    private string originalFilingCodeField;

    private string reasonForPaymentCodeField;

    private string definitionOfReasonField;

    private string nameSpecifierField;

    private string payerReferenceField;

    private string payeeNameSpecifierField;

    private string payerNameSpecifierField;

    private string payerIdentifierField;

    private string remitterDataField;

    private string foreignXchgTxnDataField;

    private string messagesField;

    private string supplementaryDataField;

    private string supplementaryDetailsField;

    private string initiatingPartyField;

    private string debtorField;

    private string ultimateDebtorField;

    private string creditorInfoField;

    private string ultimateCreditorField;

    private string tradingPartyField;

    private string proprietaryPartyField;

    private string invoicerField;

    private string invoiceeField;

    private string creditorAccountInfoField;

    private string safekeepingAccountField;

    private string debtorAgentField;

    private string creditorAgentField;

    private string intermediaryAgent1Field;

    private string intermediaryAgent2Field;

    private string intermediaryAgent3Field;

    private string receivingAgentField;

    private string deliveringAgentField;

    private string issuingAgentField;

    private string settlementPlaceField;

    private string proprietaryAgentField;

    private string amountDetailsField;

    private string availabilityField;

    private string chargesField;

    private string interestField;

    private string rltdRmtInfoField;

    private string refDocAmountField;

    private string rltdDatesField;

    private string rltdPriceField;

    private string rltdQuantitiesField;

    private string taxField;

    private string retInfoField;

    private string corporateActionField;

    private string finInstrumentIdField;

    private string additionalInformationIndicatorField;

    private string technicalInputChannelField;

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionTransactionDetailsPayeeAccount PayeeAccount
    {
        get
        {
            return payeeAccountField;
        }
        set
        {
            payeeAccountField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionTransactionDetailsCreditorAccount CreditorAccount
    {
        get
        {
            return creditorAccountField;
        }
        set
        {
            creditorAccountField = value;
        }
    }

    /// <remarks/>
    public OpusCapitaAccountsTransactionsTransactionTransactionDetailsDebtorAccount DebtorAccount
    {
        get
        {
            return debtorAccountField;
        }
        set
        {
            debtorAccountField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string FilingCode
    {
        get
        {
            return filingCodeField;
        }
        set
        {
            filingCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CustomerNumber
    {
        get
        {
            return customerNumberField;
        }
        set
        {
            customerNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string InvoiceNumber
    {
        get
        {
            return invoiceNumberField;
        }
        set
        {
            invoiceNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CardNumber
    {
        get
        {
            return cardNumberField;
        }
        set
        {
            cardNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string FilingReference
    {
        get
        {
            return filingReferenceField;
        }
        set
        {
            filingReferenceField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string OriginalFilingCode
    {
        get
        {
            return originalFilingCodeField;
        }
        set
        {
            originalFilingCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ReasonForPaymentCode
    {
        get
        {
            return reasonForPaymentCodeField;
        }
        set
        {
            reasonForPaymentCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string DefinitionOfReason
    {
        get
        {
            return definitionOfReasonField;
        }
        set
        {
            definitionOfReasonField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string NameSpecifier
    {
        get
        {
            return nameSpecifierField;
        }
        set
        {
            nameSpecifierField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string PayerReference
    {
        get
        {
            return payerReferenceField;
        }
        set
        {
            payerReferenceField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string PayeeNameSpecifier
    {
        get
        {
            return payeeNameSpecifierField;
        }
        set
        {
            payeeNameSpecifierField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string PayerNameSpecifier
    {
        get
        {
            return payerNameSpecifierField;
        }
        set
        {
            payerNameSpecifierField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string PayerIdentifier
    {
        get
        {
            return payerIdentifierField;
        }
        set
        {
            payerIdentifierField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RemitterData
    {
        get
        {
            return remitterDataField;
        }
        set
        {
            remitterDataField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ForeignXchgTxnData
    {
        get
        {
            return foreignXchgTxnDataField;
        }
        set
        {
            foreignXchgTxnDataField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Messages
    {
        get
        {
            return messagesField;
        }
        set
        {
            messagesField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string SupplementaryData
    {
        get
        {
            return supplementaryDataField;
        }
        set
        {
            supplementaryDataField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string SupplementaryDetails
    {
        get
        {
            return supplementaryDetailsField;
        }
        set
        {
            supplementaryDetailsField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string InitiatingParty
    {
        get
        {
            return initiatingPartyField;
        }
        set
        {
            initiatingPartyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Debtor
    {
        get
        {
            return debtorField;
        }
        set
        {
            debtorField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string UltimateDebtor
    {
        get
        {
            return ultimateDebtorField;
        }
        set
        {
            ultimateDebtorField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CreditorInfo
    {
        get
        {
            return creditorInfoField;
        }
        set
        {
            creditorInfoField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string UltimateCreditor
    {
        get
        {
            return ultimateCreditorField;
        }
        set
        {
            ultimateCreditorField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string TradingParty
    {
        get
        {
            return tradingPartyField;
        }
        set
        {
            tradingPartyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ProprietaryParty
    {
        get
        {
            return proprietaryPartyField;
        }
        set
        {
            proprietaryPartyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Invoicer
    {
        get
        {
            return invoicerField;
        }
        set
        {
            invoicerField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Invoicee
    {
        get
        {
            return invoiceeField;
        }
        set
        {
            invoiceeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CreditorAccountInfo
    {
        get
        {
            return creditorAccountInfoField;
        }
        set
        {
            creditorAccountInfoField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string SafekeepingAccount
    {
        get
        {
            return safekeepingAccountField;
        }
        set
        {
            safekeepingAccountField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string DebtorAgent
    {
        get
        {
            return debtorAgentField;
        }
        set
        {
            debtorAgentField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CreditorAgent
    {
        get
        {
            return creditorAgentField;
        }
        set
        {
            creditorAgentField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string IntermediaryAgent1
    {
        get
        {
            return intermediaryAgent1Field;
        }
        set
        {
            intermediaryAgent1Field = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string IntermediaryAgent2
    {
        get
        {
            return intermediaryAgent2Field;
        }
        set
        {
            intermediaryAgent2Field = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string IntermediaryAgent3
    {
        get
        {
            return intermediaryAgent3Field;
        }
        set
        {
            intermediaryAgent3Field = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ReceivingAgent
    {
        get
        {
            return receivingAgentField;
        }
        set
        {
            receivingAgentField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string DeliveringAgent
    {
        get
        {
            return deliveringAgentField;
        }
        set
        {
            deliveringAgentField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string IssuingAgent
    {
        get
        {
            return issuingAgentField;
        }
        set
        {
            issuingAgentField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string SettlementPlace
    {
        get
        {
            return settlementPlaceField;
        }
        set
        {
            settlementPlaceField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string ProprietaryAgent
    {
        get
        {
            return proprietaryAgentField;
        }
        set
        {
            proprietaryAgentField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AmountDetails
    {
        get
        {
            return amountDetailsField;
        }
        set
        {
            amountDetailsField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Availability
    {
        get
        {
            return availabilityField;
        }
        set
        {
            availabilityField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Charges
    {
        get
        {
            return chargesField;
        }
        set
        {
            chargesField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Interest
    {
        get
        {
            return interestField;
        }
        set
        {
            interestField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RltdRmtInfo
    {
        get
        {
            return rltdRmtInfoField;
        }
        set
        {
            rltdRmtInfoField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RefDocAmount
    {
        get
        {
            return refDocAmountField;
        }
        set
        {
            refDocAmountField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RltdDates
    {
        get
        {
            return rltdDatesField;
        }
        set
        {
            rltdDatesField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RltdPrice
    {
        get
        {
            return rltdPriceField;
        }
        set
        {
            rltdPriceField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RltdQuantities
    {
        get
        {
            return rltdQuantitiesField;
        }
        set
        {
            rltdQuantitiesField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Tax
    {
        get
        {
            return taxField;
        }
        set
        {
            taxField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string RetInfo
    {
        get
        {
            return retInfoField;
        }
        set
        {
            retInfoField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CorporateAction
    {
        get
        {
            return corporateActionField;
        }
        set
        {
            corporateActionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string FinInstrumentId
    {
        get
        {
            return finInstrumentIdField;
        }
        set
        {
            finInstrumentIdField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AdditionalInformationIndicator
    {
        get
        {
            return additionalInformationIndicatorField;
        }
        set
        {
            additionalInformationIndicatorField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string TechnicalInputChannel
    {
        get
        {
            return technicalInputChannelField;
        }
        set
        {
            technicalInputChannelField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionTransactionDetailsPayeeAccount
{

    private string nameField;

    private string numberField;

    private string bankNameField;

    private string accountHolderField;

    /// <remarks/>
    [XmlAttribute]
    public string Name
    {
        get
        {
            return nameField;
        }
        set
        {
            nameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Number
    {
        get
        {
            return numberField;
        }
        set
        {
            numberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BankName
    {
        get
        {
            return bankNameField;
        }
        set
        {
            bankNameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AccountHolder
    {
        get
        {
            return accountHolderField;
        }
        set
        {
            accountHolderField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionTransactionDetailsCreditorAccount
{

    private string nameField;

    private string numberField;

    private string bankNameField;

    private string bICField;

    private string accountHolderField;

    /// <remarks/>
    [XmlAttribute]
    public string Name
    {
        get
        {
            return nameField;
        }
        set
        {
            nameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Number
    {
        get
        {
            return numberField;
        }
        set
        {
            numberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BankName
    {
        get
        {
            return bankNameField;
        }
        set
        {
            bankNameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BIC
    {
        get
        {
            return bICField;
        }
        set
        {
            bICField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AccountHolder
    {
        get
        {
            return accountHolderField;
        }
        set
        {
            accountHolderField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionTransactionDetailsDebtorAccount
{

    private string nameField;

    private string numberField;

    private string bankNameField;

    private string bICField;

    private string accountHolderField;

    /// <remarks/>
    [XmlAttribute]
    public string Name
    {
        get
        {
            return nameField;
        }
        set
        {
            nameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Number
    {
        get
        {
            return numberField;
        }
        set
        {
            numberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BankName
    {
        get
        {
            return bankNameField;
        }
        set
        {
            bankNameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string BIC
    {
        get
        {
            return bICField;
        }
        set
        {
            bICField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AccountHolder
    {
        get
        {
            return accountHolderField;
        }
        set
        {
            accountHolderField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionStatus
{

    private string idField;

    private string codeField;

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Code
    {
        get
        {
            return codeField;
        }
        set
        {
            codeField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionPostingHeader
{

    private OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRow[] postingRowField;

    private string idField;

    private string currencyField;

    private string accountingCurrencyField;

    /// <remarks/>
    [XmlElement("PostingRow")]
    public OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRow[] PostingRow
    {
        get
        {
            return postingRowField;
        }
        set
        {
            postingRowField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Currency
    {
        get
        {
            return currencyField;
        }
        set
        {
            currencyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string AccountingCurrency
    {
        get
        {
            return accountingCurrencyField;
        }
        set
        {
            accountingCurrencyField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRow
{

    private OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRowDimension[] dimensionField;

    private string idField;

    private string descriptionField;

    private decimal amountField;

    private decimal amountInAccountingCurrencyField;

    private bool isCounterPostingField;

    private decimal grossField;

    private decimal netField;

    /// <remarks/>
    [XmlElement("Dimension")]
    public OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRowDimension[] Dimension
    {
        get
        {
            return dimensionField;
        }
        set
        {
            dimensionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Description
    {
        get
        {
            return descriptionField;
        }
        set
        {
            descriptionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal Amount
    {
        get
        {
            return amountField;
        }
        set
        {
            amountField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal AmountInAccountingCurrency
    {
        get
        {
            return amountInAccountingCurrencyField;
        }
        set
        {
            amountInAccountingCurrencyField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public bool IsCounterPosting
    {
        get
        {
            return isCounterPostingField;
        }
        set
        {
            isCounterPostingField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal Gross
    {
        get
        {
            return grossField;
        }
        set
        {
            grossField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public decimal Net
    {
        get
        {
            return netField;
        }
        set
        {
            netField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionPostingHeaderPostingRowDimension
{

    private string nameField;

    private string descriptionField;

    private string valueField;

    private string companySpecific_NameField;

    /// <remarks/>
    [XmlAttribute]
    public string Name
    {
        get
        {
            return nameField;
        }
        set
        {
            nameField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Description
    {
        get
        {
            return descriptionField;
        }
        set
        {
            descriptionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Value
    {
        get
        {
            return valueField;
        }
        set
        {
            valueField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string CompanySpecific_Name
    {
        get
        {
            return companySpecific_NameField;
        }
        set
        {
            companySpecific_NameField = value;
        }
    }
}

/// <remarks/>
[Serializable, DesignerCategory("code"),
 XmlType(AnonymousType = true,
     Namespace = "urn:schemas-opuscapita-com:accounts:transactions")]
public partial class OpusCapitaAccountsTransactionsTransactionVoucher
{

    private string idField;

    private DateTime dateField;

    private string numberField;

    private string documentTypeCodeField;

    private string documentTypeDescriptionField;

    private DateTime periodStartDateField;

    private DateTime periodEndDateField;

    private string periodFirstNumberField;

    private string periodLastNumberField;

    /// <remarks/>
    [XmlAttribute]
    public string Id
    {
        get
        {
            return idField;
        }
        set
        {
            idField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime Date
    {
        get
        {
            return dateField;
        }
        set
        {
            dateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string Number
    {
        get
        {
            return numberField;
        }
        set
        {
            numberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string DocumentTypeCode
    {
        get
        {
            return documentTypeCodeField;
        }
        set
        {
            documentTypeCodeField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string DocumentTypeDescription
    {
        get
        {
            return documentTypeDescriptionField;
        }
        set
        {
            documentTypeDescriptionField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime PeriodStartDate
    {
        get
        {
            return periodStartDateField;
        }
        set
        {
            periodStartDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public DateTime PeriodEndDate
    {
        get
        {
            return periodEndDateField;
        }
        set
        {
            periodEndDateField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string PeriodFirstNumber
    {
        get
        {
            return periodFirstNumberField;
        }
        set
        {
            periodFirstNumberField = value;
        }
    }

    /// <remarks/>
    [XmlAttribute]
    public string PeriodLastNumber
    {
        get
        {
            return periodLastNumberField;
        }
        set
        {
            periodLastNumberField = value;
        }
    }
}