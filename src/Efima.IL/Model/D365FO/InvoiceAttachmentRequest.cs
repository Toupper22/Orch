namespace Efima.IL.Model.D365FO;
using Efima.Layer.D365F.GenericInterface.OData.Common.Entities;

public class InvoiceAttachmentRequest
{
    public string InvoiceId { get; set; }
    public EfiDocumentAttachmentEntity DocumentAttachmentEntity { get; set; }
}
