namespace Efima.IL.Extensions.D365FO.Model;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

public class DemoEfiSalesOrderLineEntity : EfiSalesOrderLineEntity
{
    /// <summary> field LineDiscountPercentage on entity</summary>
    public decimal LineDiscountPercentage
    {
        get => GetFieldValue<decimal>(nameof(LineDiscountPercentage));
        set => SetFieldValue(nameof(LineDiscountPercentage), value);
    }
}
