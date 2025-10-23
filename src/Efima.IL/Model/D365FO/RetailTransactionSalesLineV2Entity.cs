using System;
using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for RetailTransactionSalesLines entity
/// </summary>
[Entity("RetailTransactionSalesLinesV2", EntitySingularName = "RetailTransactionSalesLineV2",
    EntityCachePersistence = EntityCachePersistence.MessageWidePersistent)]
[EntityPackage("Sales transactions V2.xml", "", "", "RetailTransactionSalesLineV2Entity")]
public class RetailTransactionSalesLineV2Entity : Entity
{
    public string OperatingUnitNumber
    {
        get => GetFieldValue<string>(nameof(OperatingUnitNumber));
        set => SetFieldValue(nameof(OperatingUnitNumber), value);
    }
    public string SalesTaxGroup
    {
        get => GetFieldValue<string>(nameof(SalesTaxGroup));
        set => SetFieldValue(nameof(SalesTaxGroup), value);
    }

    public string ItemSalesTaxGroup
    {
        get => GetFieldValue<string>(nameof(ItemSalesTaxGroup));
        set => SetFieldValue(nameof(ItemSalesTaxGroup), value);
    }

    public string Terminal
    {
        get => GetFieldValue<string>(nameof(Terminal));
        set => SetFieldValue(nameof(Terminal), value);
    }

    public string TransactionNumber
    {
        get => GetFieldValue<string>(nameof(TransactionNumber));
        set => SetFieldValue(nameof(TransactionNumber), value);
    }

    public string BarCode
    {
        get => GetFieldValue<string>(nameof(BarCode));
        set => SetFieldValue(nameof(BarCode), value);
    }

    public decimal? CostAmount
    {
        get => GetFieldValue<decimal>(nameof(CostAmount));
        set => SetFieldValue(nameof(CostAmount), value);
    }

    public string Currency
    {
        get => GetFieldValue<string>(nameof(Currency));
        set => SetFieldValue(nameof(Currency), value);
    }

    public string CustomerAccount
    {
        get => GetFieldValue<string>(nameof(CustomerAccount));
        set => SetFieldValue(nameof(CustomerAccount), value);
    }

    public decimal? CustomerDiscount
    {
        get => GetFieldValue<decimal>(nameof(CustomerDiscount));
        set => SetFieldValue(nameof(CustomerDiscount), value);
    }

    public decimal? CustomerInvoiceDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(CustomerInvoiceDiscountAmount));
        set => SetFieldValue(nameof(CustomerInvoiceDiscountAmount), value);
    }

    public decimal? CashDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(CashDiscountAmount));
        set => SetFieldValue(nameof(CashDiscountAmount), value);
    }

    public decimal? DiscountAmountWithoutTax
    {
        get => GetFieldValue<decimal>(nameof(DiscountAmountWithoutTax));
        set => SetFieldValue(nameof(DiscountAmountWithoutTax), value);
    }

    public string PriceGroups
    {
        get => GetFieldValue<string>(nameof(PriceGroups));
        set => SetFieldValue(nameof(PriceGroups), value);
    }

    public string OfferNumber
    {
        get => GetFieldValue<string>(nameof(OfferNumber));
        set => SetFieldValue(nameof(OfferNumber), value);
    }

    public decimal? DiscountAmountForPrinting
    {
        get => GetFieldValue<decimal>(nameof(DiscountAmountForPrinting));
        set => SetFieldValue(nameof(DiscountAmountForPrinting), value);
    }

    public string ModeOfDelivery
    {
        get => GetFieldValue<string>(nameof(ModeOfDelivery));
        set => SetFieldValue(nameof(ModeOfDelivery), value);
    }

    public string ElectronicDeliveryEmail
    {
        get => GetFieldValue<string>(nameof(ElectronicDeliveryEmail));
        set => SetFieldValue(nameof(ElectronicDeliveryEmail), value);
    }

    public string RetailEmailAddressContent
    {
        get => GetFieldValue<string>(nameof(RetailEmailAddressContent));
        set => SetFieldValue(nameof(RetailEmailAddressContent), value);
    }

    public NoYes? GiftCard
    {
        get => GetFieldValue<NoYes>(nameof(GiftCard));
        set => SetFieldValue(nameof(GiftCard), value);
    }

    public decimal? ReasonCodeDiscount
    {
        get => GetFieldValue<decimal>(nameof(ReasonCodeDiscount));
        set => SetFieldValue(nameof(ReasonCodeDiscount), value);
    }

    public string Warehouse
    {
        get => GetFieldValue<string>(nameof(Warehouse));
        set => SetFieldValue(nameof(Warehouse), value);
    }

    public string SerialNumber
    {
        get => GetFieldValue<string>(nameof(SerialNumber));
        set => SetFieldValue(nameof(SerialNumber), value);
    }

    public string SiteId
    {
        get => GetFieldValue<string>(nameof(SiteId));
        set => SetFieldValue(nameof(SiteId), value);
    }

    public string InventoryStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(InventoryStatus));
        set => SetFieldValue(nameof(InventoryStatus), value);
    }

    public string LotID
    {
        get => GetFieldValue<string>(nameof(LotID));
        set => SetFieldValue(nameof(LotID), value);
    }

    public string ItemId
    {
        get => GetFieldValue<string>(nameof(ItemId));
        set => SetFieldValue(nameof(ItemId), value);
    }

    public NoYes? ProductScanned
    {
        get => GetFieldValue<NoYes>(nameof(ProductScanned));
        set => SetFieldValue(nameof(ProductScanned), value);
    }

    public string ItemRelation
    {
        get => GetFieldValue<string>(nameof(ItemRelation));
        set => SetFieldValue(nameof(ItemRelation), value);
    }

    public NoYes? KeyboardProductEntry
    {
        get => GetFieldValue<NoYes>(nameof(KeyboardProductEntry));
        set => SetFieldValue(nameof(KeyboardProductEntry), value);
    }

    public decimal? LineDiscount
    {
        get => GetFieldValue<decimal>(nameof(LineDiscount));
        set => SetFieldValue(nameof(LineDiscount), value);
    }

    public decimal? LineManualDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(LineManualDiscountAmount));
        set => SetFieldValue(nameof(LineManualDiscountAmount), value);
    }

    public decimal? LineManualDiscountPercentage
    {
        get => GetFieldValue<decimal>(nameof(LineManualDiscountPercentage));
        set => SetFieldValue(nameof(LineManualDiscountPercentage), value);
    }

    public decimal? LineNumber
    {
        get => GetFieldValue<decimal>(nameof(LineNumber));
        set => SetFieldValue(nameof(LineNumber), value);
    }

    public NoYes? IsLineDiscounted
    {
        get => GetFieldValue<NoYes>(nameof(IsLineDiscounted));
        set => SetFieldValue(nameof(IsLineDiscounted), value);
    }

    public NoYes? IsLinkedProductNotOriginal
    {
        get => GetFieldValue<NoYes>(nameof(IsLinkedProductNotOriginal));
        set => SetFieldValue(nameof(IsLinkedProductNotOriginal), value);
    }

    public string ChannelListingID
    {
        get => GetFieldValue<string>(nameof(ChannelListingID));
        set => SetFieldValue(nameof(ChannelListingID), value);
    }

    public decimal? NetAmount
    {
        get => GetFieldValue<decimal>(nameof(NetAmount));
        set => SetFieldValue(nameof(NetAmount), value);
    }

    public decimal? NetAmountInclusiveTax
    {
        get => GetFieldValue<decimal>(nameof(NetAmountInclusiveTax));
        set => SetFieldValue(nameof(NetAmountInclusiveTax), value);
    }

    public decimal? NetPrice
    {
        get => GetFieldValue<decimal>(nameof(NetPrice));
        set => SetFieldValue(nameof(NetPrice), value);
    }

    public NoYes? IsOriginalOfLinkedProductList
    {
        get => GetFieldValue<NoYes>(nameof(IsOriginalOfLinkedProductList));
        set => SetFieldValue(nameof(IsOriginalOfLinkedProductList), value);
    }

    public decimal? OriginalPrice
    {
        get => GetFieldValue<decimal>(nameof(OriginalPrice));
        set => SetFieldValue(nameof(OriginalPrice), value);
    }

    public string OriginalSalesTaxGroup
    {
        get => GetFieldValue<string>(nameof(OriginalSalesTaxGroup));
        set => SetFieldValue(nameof(OriginalSalesTaxGroup), value);
    }

    public string OriginalItemSalesTaxGroup
    {
        get => GetFieldValue<string>(nameof(OriginalItemSalesTaxGroup));
        set => SetFieldValue(nameof(OriginalItemSalesTaxGroup), value);
    }

    public decimal? PeriodicDiscountAmount
    {
        get => GetFieldValue<decimal>(nameof(PeriodicDiscountAmount));
        set => SetFieldValue(nameof(PeriodicDiscountAmount), value);
    }

    public string PeriodicDiscountGroup
    {
        get => GetFieldValue<string>(nameof(PeriodicDiscountGroup));
        set => SetFieldValue(nameof(PeriodicDiscountGroup), value);
    }

    public decimal? PeriodicDiscountPercentage
    {
        get => GetFieldValue<decimal>(nameof(PeriodicDiscountPercentage));
        set => SetFieldValue(nameof(PeriodicDiscountPercentage), value);
    }

    public decimal? Price
    {
        get => GetFieldValue<decimal>(nameof(Price));
        set => SetFieldValue(nameof(Price), value);
    }

    public NoYes? IsPriceChange
    {
        get => GetFieldValue<NoYes>(nameof(IsPriceChange));
        set => SetFieldValue(nameof(IsPriceChange), value);
    }

    public NoYes? PriceInBarCode
    {
        get => GetFieldValue<NoYes>(nameof(PriceInBarCode));
        set => SetFieldValue(nameof(PriceInBarCode), value);
    }

    public decimal? Quantity
    {
        get => GetFieldValue<decimal>(nameof(Quantity));
        set => SetFieldValue(nameof(Quantity), value);
    }

    public DateOnly? RequestedReceiptDate
    {
        get => GetFieldValue<DateOnly>(nameof(RequestedReceiptDate));
        set => SetFieldValue(nameof(RequestedReceiptDate), value);
    }

    public string ReceiptNumber
    {
        get => GetFieldValue<string>(nameof(ReceiptNumber));
        set => SetFieldValue(nameof(ReceiptNumber), value);
    }

    public decimal? ReturnLineNumber
    {
        get => GetFieldValue<decimal>(nameof(ReturnLineNumber));
        set => SetFieldValue(nameof(ReturnLineNumber), value);
    }

    public NoYes? IsReturnNoSale
    {
        get => GetFieldValue<NoYes>(nameof(IsReturnNoSale));
        set => SetFieldValue(nameof(IsReturnNoSale), value);
    }

    public decimal? ReturnQuantity
    {
        get => GetFieldValue<decimal>(nameof(ReturnQuantity));
        set => SetFieldValue(nameof(ReturnQuantity), value);
    }

    public string ReturnTerminal
    {
        get => GetFieldValue<string>(nameof(ReturnTerminal));
        set => SetFieldValue(nameof(ReturnTerminal), value);
    }

    public string ReturnTransactionNumber
    {
        get => GetFieldValue<string>(nameof(ReturnTransactionNumber));
        set => SetFieldValue(nameof(ReturnTransactionNumber), value);
    }

    public string RFIDTagId
    {
        get => GetFieldValue<string>(nameof(RFIDTagId));
        set => SetFieldValue(nameof(RFIDTagId), value);
    }

    public NoYes? IsScaleProduct
    {
        get => GetFieldValue<NoYes>(nameof(IsScaleProduct));
        set => SetFieldValue(nameof(IsScaleProduct), value);
    }

    public string SectionNumber
    {
        get => GetFieldValue<string>(nameof(SectionNumber));
        set => SetFieldValue(nameof(SectionNumber), value);
    }

    public string ShelfNumber
    {
        get => GetFieldValue<string>(nameof(ShelfNumber));
        set => SetFieldValue(nameof(ShelfNumber), value);
    }

    public DateOnly? RequestedShipDate
    {
        get => GetFieldValue<DateOnly>(nameof(RequestedShipDate));
        set => SetFieldValue(nameof(RequestedShipDate), value);
    }

    public decimal? StandardNetPrice
    {
        get => GetFieldValue<decimal>(nameof(StandardNetPrice));
        set => SetFieldValue(nameof(StandardNetPrice), value);
    }

    public decimal? SalesTaxAmount
    {
        get => GetFieldValue<decimal>(nameof(SalesTaxAmount));
        set => SetFieldValue(nameof(SalesTaxAmount), value);
    }

    public decimal? TotalDiscount
    {
        get => GetFieldValue<decimal>(nameof(TotalDiscount));
        set => SetFieldValue(nameof(TotalDiscount), value);
    }

    public decimal? TotalDiscountInfoCodeLineNum
    {
        get => GetFieldValue<decimal>(nameof(TotalDiscountInfoCodeLineNum));
        set => SetFieldValue(nameof(TotalDiscountInfoCodeLineNum), value);
    }

    public decimal? TotalDiscountPercentage
    {
        get => GetFieldValue<decimal>(nameof(TotalDiscountPercentage));
        set => SetFieldValue(nameof(TotalDiscountPercentage), value);
    }

    public string TransactionCode //TODO enum
    {
        get => GetFieldValue<string>(nameof(TransactionCode));
        set => SetFieldValue(nameof(TransactionCode), value);
    }

    public string TransactionStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(TransactionStatus));
        set => SetFieldValue(nameof(TransactionStatus), value);
    }

    public string Unit
    {
        get => GetFieldValue<string>(nameof(Unit));
        set => SetFieldValue(nameof(Unit), value);
    }

    public decimal? UnitPrice
    {
        get => GetFieldValue<decimal>(nameof(UnitPrice));
        set => SetFieldValue(nameof(UnitPrice), value);
    }

    public decimal? UnitQuantity
    {
        get => GetFieldValue<decimal>(nameof(UnitQuantity));
        set => SetFieldValue(nameof(UnitQuantity), value);
    }

    public string VariantNumber
    {
        get => GetFieldValue<string>(nameof(VariantNumber));
        set => SetFieldValue(nameof(VariantNumber), value);
    }

    public NoYes? IsWeightProduct
    {
        get => GetFieldValue<NoYes>(nameof(IsWeightProduct));
        set => SetFieldValue(nameof(IsWeightProduct), value);
    }

    public NoYes? IsWeightManuallyEntered
    {
        get => GetFieldValue<NoYes>(nameof(IsWeightManuallyEntered));
        set => SetFieldValue(nameof(IsWeightManuallyEntered), value);
    }

    public decimal? LinePercentageDiscount
    {
        get => GetFieldValue<decimal>(nameof(LinePercentageDiscount));
        set => SetFieldValue(nameof(LinePercentageDiscount), value);
    }

    public DateOnly? BusinessDate
    {
        get => GetFieldValue<DateOnly>(nameof(BusinessDate));
        set => SetFieldValue(nameof(BusinessDate), value);
    }

    public DateOnly? TransactionDate
    {
        get => GetFieldValue<DateOnly>(nameof(TransactionDate));
        set => SetFieldValue(nameof(TransactionDate), value);
    }

    public decimal? TaxExemptPriceInclusiveOriginalPrice
    {
        get => GetFieldValue<decimal>(nameof(TaxExemptPriceInclusiveOriginalPrice));
        set => SetFieldValue(nameof(TaxExemptPriceInclusiveOriginalPrice), value);
    }

    public decimal? TaxExemptPriceInclusiveReductionAmount
    {
        get => GetFieldValue<decimal>(nameof(TaxExemptPriceInclusiveReductionAmount));
        set => SetFieldValue(nameof(TaxExemptPriceInclusiveReductionAmount), value);
    }
    public TimeOnly? PickupStartTime
    {
        get => GetFieldValue<TimeOnly>(nameof(PickupStartTime));
        set => SetFieldValue(nameof(PickupStartTime), value);
    }
    public TimeOnly? PickupEndTime
    {
        get => GetFieldValue<TimeOnly>(nameof(PickupEndTime));
        set => SetFieldValue(nameof(PickupEndTime), value);
    }

    public string ReturnTrackingStatus //TODO enum
    {
        get => GetFieldValue<string>(nameof(ReturnTrackingStatus));
        set => SetFieldValue(nameof(ReturnTrackingStatus), value);
    }

    public decimal? FixedPriceCharges
    {
        get => GetFieldValue<decimal>(nameof(FixedPriceCharges));
        set => SetFieldValue(nameof(FixedPriceCharges), value);
    }

    public string CancelledTransactionNumber
    {
        get => GetFieldValue<string>(nameof(CancelledTransactionNumber));
        set => SetFieldValue(nameof(CancelledTransactionNumber), value);
    }
}