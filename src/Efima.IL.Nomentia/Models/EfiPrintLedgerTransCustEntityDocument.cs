namespace Efima.Integration.Nomentia.Models;

[System.Serializable(), System.ComponentModel.DesignerCategory("code"),
 System.Xml.Serialization.XmlType(AnonymousType = true),
 System.Xml.Serialization.XmlRoot(ElementName = "Document", Namespace = "", IsNullable = false)]
public partial class EfiPrintLedgerTransCustEntityDocument
{
    private DocumentEFIPRINTLEDGERTRANSCUSTENTITY[] eFIPRINTLEDGERTRANSCUSTENTITYField;

    /// <remarks/>
    [System.Xml.Serialization.XmlElement("EFIPRINTLEDGERTRANSCUSTENTITY")]
    public DocumentEFIPRINTLEDGERTRANSCUSTENTITY[] EFIPRINTLEDGERTRANSCUSTENTITY
    {
        get
        {
            return eFIPRINTLEDGERTRANSCUSTENTITYField;
        }
        set
        {
            eFIPRINTLEDGERTRANSCUSTENTITYField = value;
        }
    }
}

/// <remarks/>
[System.Serializable(), System.ComponentModel.DesignerCategory("code"),
 System.Xml.Serialization.XmlType(AnonymousType = true),
 System.Xml.Serialization.XmlRoot(ElementName = "EFIPRINTLEDGERTRANSCUSTENTITY", Namespace = "", IsNullable = false)]
public partial class DocumentEFIPRINTLEDGERTRANSCUSTENTITY
{

    private string cUSTACCOUNTNUMField;

    private string vOUCHERField;

    private System.DateTime tRANSDATEField;

    private ulong rECID1Field;

    private ulong aCCOUNTINGEVENTField;

    private string aCCOUNTNUMField;

    private decimal aMOUNTCURField;

    private decimal aMOUNTMSTField;

    private string aPPROVEDField;

    private ulong aPPROVERField;

    private string bANKLCEXPORTLINEField;

    private string bANKREMITTANCEFILEIDField;

    private string bILLOFEXCHANGEIDField;

    private string bILLOFEXCHANGESEQNUMField;

    private string bILLOFEXCHANGESTATUSField;

    private string cANCELLEDPAYMENTField;

    private string cASHDISCCODEField;

    private string cASHPAYMENTField;

    private System.DateTime cLOSEDField;

    private string cOLLECTIONLETTERField;

    private string cOLLECTIONLETTERCODEField;

    private string cOMPANYBANKACCOUNTIDField;

    private string cONTROLNUMField;

    private string cORRECTField;

    private string cREATEDBY1Field;

    private System.DateTime cREATEDDATETIME1Field;

    private ulong cREATEDTRANSACTIONID1Field;

    private string cURRENCYCODEField;

    private string cUSTBILLINGCLASSIFICATIONField;

    private decimal cUSTEXCHADJUSTMENTREALIZEDField;

    private decimal cUSTEXCHADJUSTMENTUNREALIZEDField;

    private string cUSTOMERNAMEField;

    private string dATAAREAID1Field;

    private string dELIVERYMODEField;

    private string dIRECTDEBITMANDATEField;

    private System.DateTime dOCUMENTDATEField;

    private string dOCUMENTNUMField;

    private System.DateTime dUEDATEField;

    private string eUROTRIANGULATIONField;

    private decimal eXCHADJUSTMENTField;

    private decimal eXCHADJUSTMENTREPORTINGField;

    private decimal eXCHRATEField;

    private decimal eXCHRATESECONDField;

    private string fIXEDEXCHRATEField;

    private string iNTERESTField;

    private string iNVOICEField;

    private string iNVOICEPROJECTField;

    private System.DateTime lASTEXCHADJField;

    private decimal lASTEXCHADJRATEField;

    private decimal lASTEXCHADJRATEREPORTINGField;

    private string lASTEXCHADJVOUCHERField;

    private string lASTSETTLEACCOUNTNUMField;

    private string lASTSETTLECOMPANYField;

    private System.DateTime lASTSETTLEDATEField;

    private string lASTSETTLEVOUCHERField;

    private string mODIFIEDBY1Field;

    private System.DateTime mODIFIEDDATETIME1Field;

    private ulong mODIFIEDTRANSACTIONID1Field;

    private string oFFSETRECIDField;

    private string oRDERACCOUNTField;

    private ulong pARTITION1Field;

    private string pAYMIDField;

    private string pAYMMETHODField;

    private string pAYMMODEField;

    private string pAYMREFERENCEField;

    private string pAYMSCHEDIDField;

    private string pAYMSPECField;

    private string pOSTINGPROFILEField;

    private string pOSTINGPROFILECLOSEField;

    private string pREPAYMENTField;

    private string rEASONREFRECIDField;

    private string rECVERSION1Field;

    private decimal rEPORTINGCURRENCYAMOUNTField;

    private decimal rEPORTINGCURRENCYCROSSRATEField;

    private decimal rEPORTINGCURRENCYEXCHRATEField;

    private decimal rEPORTINGEXCHADJUSTMENTREALIZEDField;

    private decimal rEPORTINGEXCHADJUSTMENTUNREALIZEDField;

    private string rETAILSTOREIDField;

    private string rETAILTERMINALIDField;

    private string rETAILTRANSACTIONIDField;

    private decimal sETTLEAMOUNTCURField;

    private decimal sETTLEAMOUNTMSTField;

    private decimal sETTLEAMOUNTREPORTINGField;

    private string sETTLEMENTField;

    private string tHIRDPARTYBANKACCOUNTIDField;

    private string tRANSTYPEField;

    private string tXTField;

    /// <remarks/>
    public string CUSTACCOUNTNUM
    {
        get
        {
            return cUSTACCOUNTNUMField;
        }
        set
        {
            cUSTACCOUNTNUMField = value;
        }
    }

    /// <remarks/>
    public string VOUCHER
    {
        get
        {
            return vOUCHERField;
        }
        set
        {
            vOUCHERField = value;
        }
    }

    /// <remarks/>
    public System.DateTime TRANSDATE
    {
        get
        {
            return tRANSDATEField;
        }
        set
        {
            tRANSDATEField = value;
        }
    }

    /// <remarks/>
    public ulong RECID1
    {
        get
        {
            return rECID1Field;
        }
        set
        {
            rECID1Field = value;
        }
    }

    /// <remarks/>
    public ulong ACCOUNTINGEVENT
    {
        get
        {
            return aCCOUNTINGEVENTField;
        }
        set
        {
            aCCOUNTINGEVENTField = value;
        }
    }

    /// <remarks/>
    public string ACCOUNTNUM
    {
        get
        {
            return aCCOUNTNUMField;
        }
        set
        {
            aCCOUNTNUMField = value;
        }
    }

    /// <remarks/>
    public decimal AMOUNTCUR
    {
        get
        {
            return aMOUNTCURField;
        }
        set
        {
            aMOUNTCURField = value;
        }
    }

    /// <remarks/>
    public decimal AMOUNTMST
    {
        get
        {
            return aMOUNTMSTField;
        }
        set
        {
            aMOUNTMSTField = value;
        }
    }

    /// <remarks/>
    public string APPROVED
    {
        get
        {
            return aPPROVEDField;
        }
        set
        {
            aPPROVEDField = value;
        }
    }

    /// <remarks/>
    public ulong APPROVER
    {
        get
        {
            return aPPROVERField;
        }
        set
        {
            aPPROVERField = value;
        }
    }

    /// <remarks/>
    public string BANKLCEXPORTLINE
    {
        get
        {
            return bANKLCEXPORTLINEField;
        }
        set
        {
            bANKLCEXPORTLINEField = value;
        }
    }

    /// <remarks/>
    public string BANKREMITTANCEFILEID
    {
        get
        {
            return bANKREMITTANCEFILEIDField;
        }
        set
        {
            bANKREMITTANCEFILEIDField = value;
        }
    }

    /// <remarks/>
    public string BILLOFEXCHANGEID
    {
        get
        {
            return bILLOFEXCHANGEIDField;
        }
        set
        {
            bILLOFEXCHANGEIDField = value;
        }
    }

    /// <remarks/>
    public string BILLOFEXCHANGESEQNUM
    {
        get
        {
            return bILLOFEXCHANGESEQNUMField;
        }
        set
        {
            bILLOFEXCHANGESEQNUMField = value;
        }
    }

    /// <remarks/>
    public string BILLOFEXCHANGESTATUS
    {
        get
        {
            return bILLOFEXCHANGESTATUSField;
        }
        set
        {
            bILLOFEXCHANGESTATUSField = value;
        }
    }

    /// <remarks/>
    public string CANCELLEDPAYMENT
    {
        get
        {
            return cANCELLEDPAYMENTField;
        }
        set
        {
            cANCELLEDPAYMENTField = value;
        }
    }

    /// <remarks/>
    public string CASHDISCCODE
    {
        get
        {
            return cASHDISCCODEField;
        }
        set
        {
            cASHDISCCODEField = value;
        }
    }

    /// <remarks/>
    public string CASHPAYMENT
    {
        get
        {
            return cASHPAYMENTField;
        }
        set
        {
            cASHPAYMENTField = value;
        }
    }

    /// <remarks/>
    public System.DateTime CLOSED
    {
        get
        {
            return cLOSEDField;
        }
        set
        {
            cLOSEDField = value;
        }
    }

    /// <remarks/>
    public string COLLECTIONLETTER
    {
        get
        {
            return cOLLECTIONLETTERField;
        }
        set
        {
            cOLLECTIONLETTERField = value;
        }
    }

    /// <remarks/>
    public string COLLECTIONLETTERCODE
    {
        get
        {
            return cOLLECTIONLETTERCODEField;
        }
        set
        {
            cOLLECTIONLETTERCODEField = value;
        }
    }

    /// <remarks/>
    public string COMPANYBANKACCOUNTID
    {
        get
        {
            return cOMPANYBANKACCOUNTIDField;
        }
        set
        {
            cOMPANYBANKACCOUNTIDField = value;
        }
    }

    /// <remarks/>
    public string CONTROLNUM
    {
        get
        {
            return cONTROLNUMField;
        }
        set
        {
            cONTROLNUMField = value;
        }
    }

    /// <remarks/>
    public string CORRECT
    {
        get
        {
            return cORRECTField;
        }
        set
        {
            cORRECTField = value;
        }
    }

    /// <remarks/>
    public string CREATEDBY1
    {
        get
        {
            return cREATEDBY1Field;
        }
        set
        {
            cREATEDBY1Field = value;
        }
    }

    /// <remarks/>
    public System.DateTime CREATEDDATETIME1
    {
        get
        {
            return cREATEDDATETIME1Field;
        }
        set
        {
            cREATEDDATETIME1Field = value;
        }
    }

    /// <remarks/>
    public ulong CREATEDTRANSACTIONID1
    {
        get
        {
            return cREATEDTRANSACTIONID1Field;
        }
        set
        {
            cREATEDTRANSACTIONID1Field = value;
        }
    }

    /// <remarks/>
    public string CURRENCYCODE
    {
        get
        {
            return cURRENCYCODEField;
        }
        set
        {
            cURRENCYCODEField = value;
        }
    }

    /// <remarks/>
    public string CUSTBILLINGCLASSIFICATION
    {
        get
        {
            return cUSTBILLINGCLASSIFICATIONField;
        }
        set
        {
            cUSTBILLINGCLASSIFICATIONField = value;
        }
    }

    /// <remarks/>
    public decimal CUSTEXCHADJUSTMENTREALIZED
    {
        get
        {
            return cUSTEXCHADJUSTMENTREALIZEDField;
        }
        set
        {
            cUSTEXCHADJUSTMENTREALIZEDField = value;
        }
    }

    /// <remarks/>
    public decimal CUSTEXCHADJUSTMENTUNREALIZED
    {
        get
        {
            return cUSTEXCHADJUSTMENTUNREALIZEDField;
        }
        set
        {
            cUSTEXCHADJUSTMENTUNREALIZEDField = value;
        }
    }

    /// <remarks/>
    public string CUSTOMERNAME
    {
        get
        {
            return cUSTOMERNAMEField;
        }
        set
        {
            cUSTOMERNAMEField = value;
        }
    }

    /// <remarks/>
    public string DATAAREAID1
    {
        get
        {
            return dATAAREAID1Field;
        }
        set
        {
            dATAAREAID1Field = value;
        }
    }

    /// <remarks/>
    public string DELIVERYMODE
    {
        get
        {
            return dELIVERYMODEField;
        }
        set
        {
            dELIVERYMODEField = value;
        }
    }

    /// <remarks/>
    public string DIRECTDEBITMANDATE
    {
        get
        {
            return dIRECTDEBITMANDATEField;
        }
        set
        {
            dIRECTDEBITMANDATEField = value;
        }
    }

    /// <remarks/>
    public System.DateTime DOCUMENTDATE
    {
        get
        {
            return dOCUMENTDATEField;
        }
        set
        {
            dOCUMENTDATEField = value;
        }
    }

    /// <remarks/>
    public string DOCUMENTNUM
    {
        get
        {
            return dOCUMENTNUMField;
        }
        set
        {
            dOCUMENTNUMField = value;
        }
    }

    /// <remarks/>
    public System.DateTime DUEDATE
    {
        get
        {
            return dUEDATEField;
        }
        set
        {
            dUEDATEField = value;
        }
    }

    /// <remarks/>
    public string EUROTRIANGULATION
    {
        get
        {
            return eUROTRIANGULATIONField;
        }
        set
        {
            eUROTRIANGULATIONField = value;
        }
    }

    /// <remarks/>
    public decimal EXCHADJUSTMENT
    {
        get
        {
            return eXCHADJUSTMENTField;
        }
        set
        {
            eXCHADJUSTMENTField = value;
        }
    }

    /// <remarks/>
    public decimal EXCHADJUSTMENTREPORTING
    {
        get
        {
            return eXCHADJUSTMENTREPORTINGField;
        }
        set
        {
            eXCHADJUSTMENTREPORTINGField = value;
        }
    }

    /// <remarks/>
    public decimal EXCHRATE
    {
        get
        {
            return eXCHRATEField;
        }
        set
        {
            eXCHRATEField = value;
        }
    }

    /// <remarks/>
    public decimal EXCHRATESECOND
    {
        get
        {
            return eXCHRATESECONDField;
        }
        set
        {
            eXCHRATESECONDField = value;
        }
    }

    /// <remarks/>
    public string FIXEDEXCHRATE
    {
        get
        {
            return fIXEDEXCHRATEField;
        }
        set
        {
            fIXEDEXCHRATEField = value;
        }
    }

    /// <remarks/>
    public string INTEREST
    {
        get
        {
            return iNTERESTField;
        }
        set
        {
            iNTERESTField = value;
        }
    }

    /// <remarks/>
    public string INVOICE
    {
        get
        {
            return iNVOICEField;
        }
        set
        {
            iNVOICEField = value;
        }
    }

    /// <remarks/>
    public string INVOICEPROJECT
    {
        get
        {
            return iNVOICEPROJECTField;
        }
        set
        {
            iNVOICEPROJECTField = value;
        }
    }

    /// <remarks/>
    public System.DateTime LASTEXCHADJ
    {
        get
        {
            return lASTEXCHADJField;
        }
        set
        {
            lASTEXCHADJField = value;
        }
    }

    /// <remarks/>
    public decimal LASTEXCHADJRATE
    {
        get
        {
            return lASTEXCHADJRATEField;
        }
        set
        {
            lASTEXCHADJRATEField = value;
        }
    }

    /// <remarks/>
    public decimal LASTEXCHADJRATEREPORTING
    {
        get
        {
            return lASTEXCHADJRATEREPORTINGField;
        }
        set
        {
            lASTEXCHADJRATEREPORTINGField = value;
        }
    }

    /// <remarks/>
    public string LASTEXCHADJVOUCHER
    {
        get
        {
            return lASTEXCHADJVOUCHERField;
        }
        set
        {
            lASTEXCHADJVOUCHERField = value;
        }
    }

    /// <remarks/>
    public string LASTSETTLEACCOUNTNUM
    {
        get
        {
            return lASTSETTLEACCOUNTNUMField;
        }
        set
        {
            lASTSETTLEACCOUNTNUMField = value;
        }
    }

    /// <remarks/>
    public string LASTSETTLECOMPANY
    {
        get
        {
            return lASTSETTLECOMPANYField;
        }
        set
        {
            lASTSETTLECOMPANYField = value;
        }
    }

    /// <remarks/>
    public System.DateTime LASTSETTLEDATE
    {
        get
        {
            return lASTSETTLEDATEField;
        }
        set
        {
            lASTSETTLEDATEField = value;
        }
    }

    /// <remarks/>
    public string LASTSETTLEVOUCHER
    {
        get
        {
            return lASTSETTLEVOUCHERField;
        }
        set
        {
            lASTSETTLEVOUCHERField = value;
        }
    }

    /// <remarks/>
    public string MODIFIEDBY1
    {
        get
        {
            return mODIFIEDBY1Field;
        }
        set
        {
            mODIFIEDBY1Field = value;
        }
    }

    /// <remarks/>
    public System.DateTime MODIFIEDDATETIME1
    {
        get
        {
            return mODIFIEDDATETIME1Field;
        }
        set
        {
            mODIFIEDDATETIME1Field = value;
        }
    }

    /// <remarks/>
    public ulong MODIFIEDTRANSACTIONID1
    {
        get
        {
            return mODIFIEDTRANSACTIONID1Field;
        }
        set
        {
            mODIFIEDTRANSACTIONID1Field = value;
        }
    }

    /// <remarks/>
    public string OFFSETRECID
    {
        get
        {
            return oFFSETRECIDField;
        }
        set
        {
            oFFSETRECIDField = value;
        }
    }

    /// <remarks/>
    public string ORDERACCOUNT
    {
        get
        {
            return oRDERACCOUNTField;
        }
        set
        {
            oRDERACCOUNTField = value;
        }
    }

    /// <remarks/>
    public ulong PARTITION1
    {
        get
        {
            return pARTITION1Field;
        }
        set
        {
            pARTITION1Field = value;
        }
    }

    /// <remarks/>
    public string PAYMID
    {
        get
        {
            return pAYMIDField;
        }
        set
        {
            pAYMIDField = value;
        }
    }

    /// <remarks/>
    public string PAYMMETHOD
    {
        get
        {
            return pAYMMETHODField;
        }
        set
        {
            pAYMMETHODField = value;
        }
    }

    /// <remarks/>
    public string PAYMMODE
    {
        get
        {
            return pAYMMODEField;
        }
        set
        {
            pAYMMODEField = value;
        }
    }

    /// <remarks/>
    public string PAYMREFERENCE
    {
        get
        {
            return pAYMREFERENCEField;
        }
        set
        {
            pAYMREFERENCEField = value;
        }
    }

    /// <remarks/>
    public string PAYMSCHEDID
    {
        get
        {
            return pAYMSCHEDIDField;
        }
        set
        {
            pAYMSCHEDIDField = value;
        }
    }

    /// <remarks/>
    public string PAYMSPEC
    {
        get
        {
            return pAYMSPECField;
        }
        set
        {
            pAYMSPECField = value;
        }
    }

    /// <remarks/>
    public string POSTINGPROFILE
    {
        get
        {
            return pOSTINGPROFILEField;
        }
        set
        {
            pOSTINGPROFILEField = value;
        }
    }

    /// <remarks/>
    public string POSTINGPROFILECLOSE
    {
        get
        {
            return pOSTINGPROFILECLOSEField;
        }
        set
        {
            pOSTINGPROFILECLOSEField = value;
        }
    }

    /// <remarks/>
    public string PREPAYMENT
    {
        get
        {
            return pREPAYMENTField;
        }
        set
        {
            pREPAYMENTField = value;
        }
    }

    /// <remarks/>
    public string REASONREFRECID
    {
        get
        {
            return rEASONREFRECIDField;
        }
        set
        {
            rEASONREFRECIDField = value;
        }
    }

    /// <remarks/>
    public string RECVERSION1
    {
        get
        {
            return rECVERSION1Field;
        }
        set
        {
            rECVERSION1Field = value;
        }
    }

    /// <remarks/>
    public decimal REPORTINGCURRENCYAMOUNT
    {
        get
        {
            return rEPORTINGCURRENCYAMOUNTField;
        }
        set
        {
            rEPORTINGCURRENCYAMOUNTField = value;
        }
    }

    /// <remarks/>
    public decimal REPORTINGCURRENCYCROSSRATE
    {
        get
        {
            return rEPORTINGCURRENCYCROSSRATEField;
        }
        set
        {
            rEPORTINGCURRENCYCROSSRATEField = value;
        }
    }

    /// <remarks/>
    public decimal REPORTINGCURRENCYEXCHRATE
    {
        get
        {
            return rEPORTINGCURRENCYEXCHRATEField;
        }
        set
        {
            rEPORTINGCURRENCYEXCHRATEField = value;
        }
    }

    /// <remarks/>
    public decimal REPORTINGEXCHADJUSTMENTREALIZED
    {
        get
        {
            return rEPORTINGEXCHADJUSTMENTREALIZEDField;
        }
        set
        {
            rEPORTINGEXCHADJUSTMENTREALIZEDField = value;
        }
    }

    /// <remarks/>
    public decimal REPORTINGEXCHADJUSTMENTUNREALIZED
    {
        get
        {
            return rEPORTINGEXCHADJUSTMENTUNREALIZEDField;
        }
        set
        {
            rEPORTINGEXCHADJUSTMENTUNREALIZEDField = value;
        }
    }

    /// <remarks/>
    public string RETAILSTOREID
    {
        get
        {
            return rETAILSTOREIDField;
        }
        set
        {
            rETAILSTOREIDField = value;
        }
    }

    /// <remarks/>
    public string RETAILTERMINALID
    {
        get
        {
            return rETAILTERMINALIDField;
        }
        set
        {
            rETAILTERMINALIDField = value;
        }
    }

    /// <remarks/>
    public string RETAILTRANSACTIONID
    {
        get
        {
            return rETAILTRANSACTIONIDField;
        }
        set
        {
            rETAILTRANSACTIONIDField = value;
        }
    }

    /// <remarks/>
    public decimal SETTLEAMOUNTCUR
    {
        get
        {
            return sETTLEAMOUNTCURField;
        }
        set
        {
            sETTLEAMOUNTCURField = value;
        }
    }

    /// <remarks/>
    public decimal SETTLEAMOUNTMST
    {
        get
        {
            return sETTLEAMOUNTMSTField;
        }
        set
        {
            sETTLEAMOUNTMSTField = value;
        }
    }

    /// <remarks/>
    public decimal SETTLEAMOUNTREPORTING
    {
        get
        {
            return sETTLEAMOUNTREPORTINGField;
        }
        set
        {
            sETTLEAMOUNTREPORTINGField = value;
        }
    }

    /// <remarks/>
    public string SETTLEMENT
    {
        get
        {
            return sETTLEMENTField;
        }
        set
        {
            sETTLEMENTField = value;
        }
    }

    /// <remarks/>
    public string THIRDPARTYBANKACCOUNTID
    {
        get
        {
            return tHIRDPARTYBANKACCOUNTIDField;
        }
        set
        {
            tHIRDPARTYBANKACCOUNTIDField = value;
        }
    }

    /// <remarks/>
    public string TRANSTYPE
    {
        get
        {
            return tRANSTYPEField;
        }
        set
        {
            tRANSTYPEField = value;
        }
    }

    /// <remarks/>
    public string TXT
    {
        get
        {
            return tXTField;
        }
        set
        {
            tXTField = value;
        }
    }
}