namespace Efima.IL.Extensions.D365FO.Model;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;
using Efima.Layer.D365F.GenericInterface.Core.Model.Collections;

using System;
using System.Collections.Generic;

/// <summary>
/// Proxy class for MainAccounts entity
/// </summary>
[Entity("CustomerPaymentJournalLines",
    EntitySingularName = "CustomerPaymentJournalLine",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent,
    IsCompanySpecific = true)]
[EntityPackage("Customer payment journal line.xml", targetEntityName: "EFICUSCUSTOMERPAYMENTJOURNALLINEENTITY")]
public class CustomerPaymentJournalLineEntity : Entity
{
    public override IList<EntityFieldsCollection> EntityUniqueKeys
    {
        get
        {
            var keysCollections = new List<EntityFieldsCollection>
            {
                ConstructKeysCollection(EntityField.dataAreaId_FieldAlias, nameof(JournalBatchNumber), nameof(LineNumber))
            };
            return keysCollections;
        }
    }
    /// <summary> Field JournalBatchNumber on entity </summary>
    public string JournalBatchNumber
    {
        get => GetFieldValue<string>("JournalBatchNumber");
        set => SetFieldValue("JournalBatchNumber", value);
    }
    /// <summary> Field LineNumber on entity </summary>
    public decimal LineNumber
    {
        get => GetFieldValue<decimal>("LineNumber");
        set => SetFieldValue("LineNumber", value);
    }
    /// <summary> Field UseSalesTaxDirectionFromMainAccount on entity </summary>
    public NoYes UseSalesTaxDirectionFromMainAccount
    {
        get => GetFieldValue<NoYes>("UseSalesTaxDirectionFromMainAccount");
        set => SetFieldValue("UseSalesTaxDirectionFromMainAccount", value);
    }
    /// <summary> Field MarkedInvoice on entity </summary>
    public string MarkedInvoice
    {
        get => GetFieldValue<string>("MarkedInvoice");
        set => SetFieldValue("MarkedInvoice", value);
    }
    /// <summary> Field Voucher on entity </summary>
    public string Voucher
    {
        get => GetFieldValue<string>("Voucher");
        set => SetFieldValue("Voucher", value);
    }
    /// <summary> Field DepositNumber on entity </summary>
    public string DepositNumber
    {
        get => GetFieldValue<string>("DepositNumber");
        set => SetFieldValue("DepositNumber", value);
    }
    /// <summary> Field ItemWithholdingTaxGroup on entity </summary>
    public string ItemWithholdingTaxGroup
    {
        get => GetFieldValue<string>("ItemWithholdingTaxGroup");
        set => SetFieldValue("ItemWithholdingTaxGroup", value);
    }
    /// <summary> Field OffsetAccountType on entity </summary>
    public string OffsetAccountType
    {
        get => GetFieldValue<string>("OffsetAccountType");
        set => SetFieldValue("OffsetAccountType", value);
    }
    /// <summary> Field PostdatedCheckCashierDisplayValue on entity </summary>
    public string PostdatedCheckCashierDisplayValue
    {
        get => GetFieldValue<string>("PostdatedCheckCashierDisplayValue");
        set => SetFieldValue("PostdatedCheckCashierDisplayValue", value);
    }
    /// <summary> Field PostdatedCheckMaturityDate on entity </summary>
    public DateTime? PostdatedCheckMaturityDate
    {
        get => GetFieldValue<DateTime?>("PostdatedCheckMaturityDate");
        set => SetFieldValue("PostdatedCheckMaturityDate", value);
    }
    /// <summary> Field SettleVoucher on entity </summary>
    public string SettleVoucher
    {
        get => GetFieldValue<string>("SettleVoucher");
        set => SetFieldValue("SettleVoucher", value);
    }
    /// <summary> Field TransactionDate on entity </summary>
    public DateTime? TransactionDate
    {
        get => GetFieldValue<DateTime?>("TransactionDate");
        set => SetFieldValue("TransactionDate", value);
    }
    /// <summary> Field BankTransactionType on entity </summary>
    public string BankTransactionType
    {
        get => GetFieldValue<string>("BankTransactionType");
        set => SetFieldValue("BankTransactionType", value);
    }
    /// <summary> Field PaymentReference on entity </summary>
    public string PaymentReference
    {
        get => GetFieldValue<string>("PaymentReference");
        set => SetFieldValue("PaymentReference", value);
    }
    /// <summary> Field CustomerName on entity </summary>
    public string CustomerName
    {
        get => GetFieldValue<string>("CustomerName");
        set => SetFieldValue("CustomerName", value);
    }
    /// <summary> Field DebitAmount on entity </summary>
    public decimal DebitAmount
    {
        get => GetFieldValue<decimal>("DebitAmount");
        set => SetFieldValue("DebitAmount", value);
    }
    /// <summary> Field TaxItemGroup on entity </summary>
    public string TaxItemGroup
    {
        get => GetFieldValue<string>("TaxItemGroup");
        set => SetFieldValue("TaxItemGroup", value);
    }
    /// <summary> Field ThirdPartyBankAccountId on entity </summary>
    public string ThirdPartyBankAccountId
    {
        get => GetFieldValue<string>("ThirdPartyBankAccountId");
        set => SetFieldValue("ThirdPartyBankAccountId", value);
    }
    /// <summary> Field TransactionText on entity </summary>
    public string TransactionText
    {
        get => GetFieldValue<string>("TransactionText");
        set => SetFieldValue("TransactionText", value);
    }
    /// <summary> Field PostdatedCheckNumber on entity </summary>
    public string PostdatedCheckNumber
    {
        get => GetFieldValue<string>("PostdatedCheckNumber");
        set => SetFieldValue("PostdatedCheckNumber", value);
    }
    /// <summary> Field OffsetAccountDisplayValue on entity </summary>
    public string OffsetAccountDisplayValue
    {
        get => GetFieldValue<string>("OffsetAccountDisplayValue");
        set => SetFieldValue("OffsetAccountDisplayValue", value);
    }
    /// <summary> Field AccountDisplayValue on entity </summary>
    public string AccountDisplayValue
    {
        get => GetFieldValue<string>("AccountDisplayValue");
        set => SetFieldValue("AccountDisplayValue", value);
    }
    /// <summary> Field DefaultDimensionsForAccountDisplayValue on entity </summary>
    public string DefaultDimensionsForAccountDisplayValue
    {
        get => GetFieldValue<string>("DefaultDimensionsForAccountDisplayValue");
        set => SetFieldValue("DefaultDimensionsForAccountDisplayValue", value);
    }
    /// <summary> Field PostdatedCheckOriginalCheckNumber on entity </summary>
    public string PostdatedCheckOriginalCheckNumber
    {
        get => GetFieldValue<string>("PostdatedCheckOriginalCheckNumber");
        set => SetFieldValue("PostdatedCheckOriginalCheckNumber", value);
    }
    /// <summary> Field PaymentMethodName on entity </summary>
    public string PaymentMethodName
    {
        get => GetFieldValue<string>("PaymentMethodName");
        set => SetFieldValue("PaymentMethodName", value);
    }
    /// <summary> Field CentralBankImportDate on entity </summary>
    public DateTime? CentralBankImportDate
    {
        get => GetFieldValue<DateTime?>("CentralBankImportDate");
        set => SetFieldValue("CentralBankImportDate", value);
    }
    /// <summary> Field OffsetTransactionText on entity </summary>
    public string OffsetTransactionText
    {
        get => GetFieldValue<string>("OffsetTransactionText");
        set => SetFieldValue("OffsetTransactionText", value);
    }
    /// <summary> Field MarkedInvoiceCompany on entity </summary>
    public string MarkedInvoiceCompany
    {
        get => GetFieldValue<string>("MarkedInvoiceCompany");
        set => SetFieldValue("MarkedInvoiceCompany", value);
    }
    /// <summary> Field UseABankDepositSlip on entity </summary>
    public NoYes UseABankDepositSlip
    {
        get => GetFieldValue<NoYes>("UseABankDepositSlip");
        set => SetFieldValue("UseABankDepositSlip", value);
    }
    /// <summary> Field PaymentSpecification on entity </summary>
    public string PaymentSpecification
    {
        get => GetFieldValue<string>("PaymentSpecification");
        set => SetFieldValue("PaymentSpecification", value);
    }
    /// <summary> Field AccountType on entity </summary>
    public string AccountType
    {
        get => GetFieldValue<string>("AccountType");
        set => SetFieldValue("AccountType", value);
    }
    /// <summary> Field TaxGroup on entity </summary>
    public string TaxGroup
    {
        get => GetFieldValue<string>("TaxGroup");
        set => SetFieldValue("TaxGroup", value);
    }
    /// <summary> Field ExchangeRate on entity </summary>
    public decimal ExchangeRate
    {
        get => GetFieldValue<decimal>("ExchangeRate");
        set => SetFieldValue("ExchangeRate", value);
    }
    /// <summary> Field ReportingCurrencyExchRate on entity </summary>
    public decimal ReportingCurrencyExchRate
    {
        get => GetFieldValue<decimal>("ReportingCurrencyExchRate");
        set => SetFieldValue("ReportingCurrencyExchRate", value);
    }
    /// <summary> Field PaymentId on entity </summary>
    public string PaymentId
    {
        get => GetFieldValue<string>("PaymentId");
        set => SetFieldValue("PaymentId", value);
    }
    /// <summary> Field PostingProfile on entity </summary>
    public string PostingProfile
    {
        get => GetFieldValue<string>("PostingProfile");
        set => SetFieldValue("PostingProfile", value);
    }
    /// <summary> Field CalculateWithholdingTax on entity </summary>
    public NoYes CalculateWithholdingTax
    {
        get => GetFieldValue<NoYes>("CalculateWithholdingTax");
        set => SetFieldValue("CalculateWithholdingTax", value);
    }
    /// <summary> Field PostdatedCheckReasonForStop on entity </summary>
    public string PostdatedCheckReasonForStop
    {
        get => GetFieldValue<string>("PostdatedCheckReasonForStop");
        set => SetFieldValue("PostdatedCheckReasonForStop", value);
    }
    /// <summary> Field CreditAmount on entity </summary>
    public decimal CreditAmount
    {
        get => GetFieldValue<decimal>("CreditAmount");
        set => SetFieldValue("CreditAmount", value);
    }
    /// <summary> Field OffsetCompany on entity </summary>
    public string OffsetCompany
    {
        get => GetFieldValue<string>("OffsetCompany");
        set => SetFieldValue("OffsetCompany", value);
    }
    /// <summary> Field IsPrepayment on entity </summary>
    public NoYes IsPrepayment
    {
        get => GetFieldValue<NoYes>("IsPrepayment");
        set => SetFieldValue("IsPrepayment", value);
    }
    /// <summary> Field DefaultDimensionsForOffsetAccountDisplayValue on entity </summary>
    public string DefaultDimensionsForOffsetAccountDisplayValue
    {
        get => GetFieldValue<string>("DefaultDimensionsForOffsetAccountDisplayValue");
        set => SetFieldValue("DefaultDimensionsForOffsetAccountDisplayValue", value);
    }
    /// <summary> Field ReportingCurrencyExchRateSecondary on entity </summary>
    public decimal ReportingCurrencyExchRateSecondary
    {
        get => GetFieldValue<decimal>("ReportingCurrencyExchRateSecondary");
        set => SetFieldValue("ReportingCurrencyExchRateSecondary", value);
    }
    /// <summary> Field CurrencyCode on entity </summary>
    public string CurrencyCode
    {
        get => GetFieldValue<string>("CurrencyCode");
        set => SetFieldValue("CurrencyCode", value);
    }
    /// <summary> Field Company on entity </summary>
    public string Company
    {
        get => GetFieldValue<string>("Company");
        set => SetFieldValue("Company", value);
    }
    /// <summary> Field SecondaryExchangeRate on entity </summary>
    public decimal SecondaryExchangeRate
    {
        get => GetFieldValue<decimal>("SecondaryExchangeRate");
        set => SetFieldValue("SecondaryExchangeRate", value);
    }
    /// <summary> Field PostdatedCheckReceivedDate on entity </summary>
    public DateTime? PostdatedCheckReceivedDate
    {
        get => GetFieldValue<DateTime?>("PostdatedCheckReceivedDate");
        set => SetFieldValue("PostdatedCheckReceivedDate", value);
    }
    /// <summary> Field PostdatedCheckBankBranch on entity </summary>
    public string PostdatedCheckBankBranch
    {
        get => GetFieldValue<string>("PostdatedCheckBankBranch");
        set => SetFieldValue("PostdatedCheckBankBranch", value);
    }
    /// <summary> Field CentralBankPurposeCode on entity </summary>
    public string CentralBankPurposeCode
    {
        get => GetFieldValue<string>("CentralBankPurposeCode");
        set => SetFieldValue("CentralBankPurposeCode", value);
    }
    /// <summary> Field PostdatedCheckReplacementComments on entity </summary>
    public string PostdatedCheckReplacementComments
    {
        get => GetFieldValue<string>("PostdatedCheckReplacementComments");
        set => SetFieldValue("PostdatedCheckReplacementComments", value);
    }
    /// <summary> Field PostdatedCheckStopPayment on entity </summary>
    public NoYes PostdatedCheckStopPayment
    {
        get => GetFieldValue<NoYes>("PostdatedCheckStopPayment");
        set => SetFieldValue("PostdatedCheckStopPayment", value);
    }
    /// <summary> Field PostdatedCheckBankName on entity </summary>
    public string PostdatedCheckBankName
    {
        get => GetFieldValue<string>("PostdatedCheckBankName");
        set => SetFieldValue("PostdatedCheckBankName", value);
    }
    /// <summary> Field PaymentNotes on entity </summary>
    public string PaymentNotes
    {
        get => GetFieldValue<string>("PaymentNotes");
        set => SetFieldValue("PaymentNotes", value);
    }
    /// <summary> Field CentralBankPurposeText on entity </summary>
    public string CentralBankPurposeText
    {
        get => GetFieldValue<string>("CentralBankPurposeText");
        set => SetFieldValue("CentralBankPurposeText", value);
    }
    /// <summary> Field EfiCusLinkId on entity </summary>
    public override string EfiLinkId
    {
        get => GetFieldValue<string>("EfiCusLinkId");
        set => SetFieldValue("EfiCusLinkId", value);
    }
    /// <summary> Field EfiCusLinkIdParent on entity </summary>
    public override string EfiLinkIdParent
    {
        get => GetFieldValue<string>("EfiCusLinkIdParent");
        set => SetFieldValue("EfiCusLinkIdParent", value);
    }
}
