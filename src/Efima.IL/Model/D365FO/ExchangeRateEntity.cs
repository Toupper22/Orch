using Efima.Layer.D365F.GenericInterface.Core.Cache.Enums;
using Efima.Layer.D365F.GenericInterface.Core.Model;
using Efima.Layer.D365F.GenericInterface.Core.Model.Attributes;
using System;

namespace Efima.IL.Model.D365FO;

/// <summary>
/// Proxy class for ExchangeRates entity
/// </summary>
[Entity("ExchangeRates", EntitySingularName = "ExchangeRate",
	EntityCachePersistence = EntityCachePersistence.None)]
[EntityPackage("Exchange rates.xml", "Resources.ExchangeRates_Manifest.xml", "Include.PackageHeader.xml", "ExchangeRateEntity")]
public class ExchangeRateEntity : Entity
{
	public ExchangeRateEntity()
	{
		Properties.IsCompanySpecific = false;
	}

	public string ConversionFactor
	{
		get => GetFieldValue<string>(nameof(ConversionFactor));
		set => SetFieldValue(nameof(ConversionFactor), value);
	}
	public DateTime? EndDate
	{
		get => GetFieldValue<DateTime?>(nameof(EndDate));
		set => SetFieldValue(nameof(EndDate), value);
	}
	public string FromCurrency
	{
		get => GetFieldValue<string>(nameof(FromCurrency));
		set => SetFieldValue(nameof(FromCurrency), value);
	}
	public double Rate
	{
		get => GetFieldValue<double>(nameof(Rate));
		set => SetFieldValue(nameof(Rate), value);
	}
	public string RateTypeName
	{
		get => GetFieldValue<string>(nameof(RateTypeName));
		set => SetFieldValue(nameof(RateTypeName), value);
	}
	public string RateTypeDescription
	{
		get => GetFieldValue<string>(nameof(RateTypeDescription));
		set => SetFieldValue(nameof(RateTypeDescription), value);
	}
	public DateTime? StartDate
	{
		get => GetFieldValue<DateTime?>(nameof(StartDate));
		set => SetFieldValue(nameof(StartDate), value);
	}
	public string ToCurrency
	{
		get => GetFieldValue<string>(nameof(ToCurrency));
		set => SetFieldValue(nameof(ToCurrency), value);
	}
}
