using EBook_Data.DataAccess;

namespace EBook_Data.Dtos
{
    #region Page Setup
    public class P_PageGroup_Result
    {
        public int RowNo { get; set; }
        public int PG_ID { get; set; }
        public string Ery_PG_ID
        {
            get
            {
                return Crypto.EncryptNumericToStringWithOutNull(PG_ID);
            }
        }
        public string PageGroupName { get; set; }
        public int Sort_ { get; set; }
        public bool IsHide { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_Page_Result
    {
        public int RowNo { get; set; }
        public int P_ID { get; set; }
        public string Ery_P_ID
        {
            get
            {
                return Crypto.EncryptNumericToStringWithOutNull(P_ID);
            }
        }
        public int PG_ID { get; set; }
        public string Ery_PG_ID
        {
            get
            {
                return Crypto.EncryptNumericToStringWithOutNull(PG_ID);
            }
        }
        public int Application_MTV_ID { get; set; }
        public string PageName { get; set; }
        public string PageGroupName { get; set; }
        public string PageURL { get; set; }
        public string Application { get; set; }
        public int Sort_ { get; set; }
        public bool IsHide { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_AddOrEdit_PageGroup_Response
    {
        public int PG_ID { get; set; }
        public string PageGroupName { get; set; }
        public bool IsHide { get; set; }
        public bool Active { get; set; }
    }
    public class P_AddOrEdit_Page_Response
    {
        public int P_ID { get; set; }
        public int PG_ID { get; set; }
        public string PageName { get; set; }
        public string PageUrl { get; set; }
        public int Application_MTV_ID { get; set; }
        public bool IsHide { get; set; }
        public bool Active { get; set; }
    }

    public class P_PageChart_Response
    {
        public int? AppID { get; set; }
        public string? UserName { get; set; }
        public int? RoleID { get; set; }
    }
    public class P_Get_PageChart_TreeView
    {
        public int App_ID { get; set; }
        public string Application { get; set; }
        public bool IsAllChecked
        {
            get
            {
                bool Ret = false;
                if (pageGroupInfo != null)
                {
                    if (pageGroupInfo.Count > 0)
                    {
                        Ret = true;
                        for (int i = 0; i <= pageGroupInfo.Count - 1; i++)
                        {
                            if (pageGroupInfo[i].IsAllChecked == false && pageGroupInfo[i].IsChildExists)
                            {
                                Ret = false;
                                break;
                            }
                        }
                    }
                }
                return Ret;
            }
        }
        public bool IsChildExists
        {
            get
            {
                bool Ret = false;
                if (pageGroupInfo != null)
                {
                    if (pageGroupInfo.Count > 0)
                        for (int i = 0; i <= pageGroupInfo.Count - 1; i++)
                        {
                            if (pageGroupInfo[i].IsChildExists)
                            {
                                Ret = true;
                                break;
                            }
                        }
                }
                return Ret;
            }
        }
        public List<PageGroupInfo> pageGroupInfo { get; set; }
    }
    #endregion Page Setup

    #region RoleSetup
    public class P_Role_Result
    {
        public int rowno { get; set; }
        public int R_ID { get; set; }
        public string RoleName { get; set; }
        public int Sort_ { get; set; }
        public int IsActive { get; set; }

    }
    public class P_RoleGroup_Result
    {
        public int rowno { get; set; }
        public int RG_ID { get; set; }
        public string RoleGroupName { get; set; }
        public int Sort_ { get; set; }
        public int IsActive { get; set; }

    }
    public class P_RoleGroupMap_Result
    {
        public int rowno { get; set; }
        public int RGM_ID { get; set; }
        public int R_ID { get; set; }
        public int RG_ID { get; set; }
        public string RoleName { get; set; }
        public string RoleGroupName { get; set; }
        public int IsActive { get; set; }
    }
    public class P_DepartmentRoleMap_Result
    {
        public int rowno { get; set; }
        public int DRM_ID { get; set; }
        public int R_ID { get; set; }
        public int D_ID { get; set; }
        public string RoleName { get; set; }
        public string DepartmentName { get; set; }
        public int IsActive { get; set; }
    }
    public class P_AddOrEdit_Role_Response
    {
        public int RoleID { get; set; }
        public string RoleName { get; set; }
        public bool Active { get; set; }
    }
    public class P_AddOrEdit_Role_Group_Response
    {
        public int RoleGroupID { get; set; }
        public string RoleGroupName { get; set; }
        public bool Active { get; set; }
    }
    public class P_AddOrEdit_Role_Group_Mapping_Response
    {
        public int RoleGroupMappingID { get; set; }
        public int RoleID { get; set; }
        public int RoleGroupID { get; set; }
        public bool Active { get; set; }
    }
    public class P_AddOrEdit_Department_Role_Mapping_Response
    {
        public int DepartmentRoleMappingID { get; set; }
        public int RoleID { get; set; }
        public int DepartmentID { get; set; }
        public bool Active { get; set; }
    }
    #endregion RoleSetup

    #region RightsSetup
    public class P_PageRight_Result
    {
        public int rowno { get; set; }
        public int PR_ID { get; set; }
        public int P_ID { get; set; }
        public string PageName { get; set; }
        public string PR_CODE { get; set; }
        public string PageRightName { get; set; }
        public string PageRightType_MTV_CODE { get; set; }
        public int Sort_ { get; set; }
        public bool IsHide { get; set; }
        public bool IsActive { get; set; }

    }
    public class P_RolePageRight_Result
    {
        public int rowno { get; set; }
        public int RPRM_ID { get; set; }
        public int R_ID { get; set; }
        public int PR_ID { get; set; }
        public string RoleName { get; set; }
        public string PageRightName { get; set; }
        public bool IsRightActive { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_UserRoleMap_Result
    {
        public int rowno { get; set; }
        public int URM_ID { get; set; }
        public int R_ID { get; set; }
        public string USERNAME { get; set; }
        public string RoleName { get; set; }
        public bool IsGroupRoleID { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_AddOrEdit_PageRights_Response
    {
        public int PR_ID { get; set; }
        public int P_ID { get; set; }
        public string PR_CODE { get; set; }
        public string PageRightName { get; set; }
        public string PageRightType { get; set; }
        public bool IsHide { get; set; }
        public bool Active { get; set; }
    }
    public class P_AddOrEdit_RolePageRights_Response
    {
        public int RPRM_ID { get; set; }
        public int R_ID { get; set; }
        public int PR_ID { get; set; }
        public bool IsRightActive { get; set; }
        public bool Active { get; set; }
    }

    public class P_AddOrEdit_RolePageRights_TreeView
    {
        public int R_ID { get; set; }
        public string RoleName { get; set; }
        public bool IsAllChecked
        {
            get
            {
                bool Ret = false;
                if (pageGroupInfo != null)
                {
                    if (pageGroupInfo.Count > 0)
                    {
                        Ret = true;
                        for (int i = 0; i <= pageGroupInfo.Count - 1; i++)
                        {
                            if (pageGroupInfo[i].IsAllChecked == false && pageGroupInfo[i].IsChildExists)
                            {
                                Ret = false;
                                break;
                            }
                        }
                    }
                }
                return Ret;
            }
        }
        public bool IsChildExists
        {
            get
            {
                bool Ret = false;
                if (pageGroupInfo != null)
                {
                    if (pageGroupInfo.Count > 0)
                        for (int i = 0; i <= pageGroupInfo.Count - 1; i++)
                        {
                            if (pageGroupInfo[i].IsChildExists)
                            {
                                Ret = true;
                                break;
                            }
                        }
                }
                return Ret;
            }
        }
        public List<PageGroupInfo> pageGroupInfo { get; set; }
    }
    public class P_Sync_RolePageRights_TreeView
    {
        public int RoleID { get; set; }
        public int RoleIDCompare { get; set; }
        public int CopyR_ID { get; set; }
        public int CopyPG_ID { get; set; }
        public int CopyP_ID { get; set; }
        public bool? Active { get; set; }
    }
    public class PageGroupInfo
    {
        public int PG_ID { get; set; }
        public string PageGroupName { get; set; }
        public int PGSort_ { get; set; }
        public bool IsAllChecked
        {
            get
            {
                bool Ret = false;
                if (pageInfo != null)
                {
                    if (pageInfo.Count > 0)
                    {
                        Ret = true;
                        for (int i = 0; i <= pageInfo.Count - 1; i++)
                        {
                            if (pageInfo[i].IsAllChecked == false && pageInfo[i].IsChildExists)
                            {
                                Ret = false;
                                break;
                            }
                        }
                    }
                }
                return Ret;
            }
        }
        public bool IsChildExists
        {
            get
            {
                bool Ret = false;
                if (pageInfo != null)
                {
                    if (pageInfo.Count > 0)
                        for (int i = 0; i <= pageInfo.Count - 1; i++)
                        {
                            if (pageInfo[i].IsChildExists)
                            {
                                Ret = true;
                                break;
                            }
                        }
                }
                return Ret;
            }
        }
        public List<PageInfo> pageInfo { get; set; }
    }
    public class PageInfo
    {
        public int P_ID { get; set; }
        public string PageName { get; set; }
        public int PSort_ { get; set; }
        public bool IsAllChecked
        {
            get
            {
                bool Ret = false;
                if (pageRightsInfo != null)
                {
                    if (pageRightsInfo.Count > 0)
                    {
                        Ret = true;
                        for (int i = 0; i <= pageRightsInfo.Count - 1; i++)
                        {
                            if (pageRightsInfo[i].IsRightActive == false)
                            {
                                Ret = false;
                                break;
                            }
                        }
                    }
                }
                return Ret;
            }
        }
        public bool IsChildExists
        {
            get
            {
                bool Ret = false;
                if (pageRightsInfo != null)
                {
                    if (pageRightsInfo.Count > 0)
                        Ret = true;
                }
                return Ret;
            }
        }
        public List<PageRightInfo> pageRightsInfo { get; set; }
    }
    public class PageRightInfo
    {
        public int PR_ID { get; set; }
        public string PR_CODE { get; set; }
        public string PageRightName { get; set; }
        public string PageRightType_MTV_CODE { get; set; }
        public int PRSort_ { get; set; }
        public bool IsRightActive { get; set; }
    }
    public class P_AddOrEdit_UserRoleMapping_Response
    {
        public int URM_ID { get; set; }
        public int R_ID { get; set; }
        public string UNAME { get; set; }
        public bool IsGroupRoleID { get; set; }
        public bool Active { get; set; }
    }
    #endregion RightsSetup

    #region DepartmentSetup
    public class P_Department_Result
    {
        public int rowno { get; set; }
        public int D_ID { get; set; }
        public string DepartmentName { get; set; }
        public int Sort_ { get; set; }
        public bool IsHidden { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_AddOrEdit_Department_Response
    {
        public int D_ID { get; set; }
        public string DepartmentName { get; set; }
        public bool IsHidden { get; set; }
        public bool Active { get; set; }
    }

    public class CardItems
    {
        public P_Department_Result C1 { get; set; } = new P_Department_Result();
        public P_Department_Result C2 { get; set; } = new P_Department_Result();
        public P_Department_Result C3 { get; set; } = new P_Department_Result();
        public P_Department_Result C4 { get; set; } = new P_Department_Result();
    }
    #endregion

    #region MasterSetup
    public class P_MT_Result
    {
        public int rowno { get; set; }
        public int MT_ID { get; set; }
        public string MasterTypeName { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_AddOrEdit_MT_Response
    {
        public int MT_ID { get; set; }
        public string MasterTypeName { get; set; }
        public string Description { get; set; }
        public bool Active { get; set; }
    }
    public class P_MTV_Result
    {
        public int rowno { get; set; }
        public int MTV_ID { get; set; }
        public int MT_ID { get; set; }
        public string? MTV_CODE { get; set; }
        public string MasterType { get; set; }
        public string MasterTypeValue { get; set; }
        public int Sort_ { get; set; }
        public int Sub_MTV_ID { get; set; }
        public string? Sub_MTV_Name { get; set; }
        public bool IsActive { get; set; }
    }
    public class P_AddOrEdit_MTV_Response
    {
        public int MTV_ID { get; set; }
        public int MT_ID { get; set; }
        public string MTV_CODE { get; set; }
        public string MasterTypeValueName { get; set; }
        public int Sub_MTV_ID { get; set; }
        public bool Active { get; set; }
    }
    #endregion MasterSetup

    #region AuditHistory
    public class P_AuditHistory_Result
    {
        public int rowno { get; set; }
        public int AH_ID { get; set; }
        public int AC_ID { get; set; }
        public int AuditType_MTV_ID { get; set; }
        public int Source_MTV_ID { get; set; }
        public string TableName { get; set; }
        public string DbName { get; set; }
        public string ColumnName { get; set; }
        public string REF_NO { get; set; }
        public string MasterTypeValueAudit { get; set; }
        public string RefNo1 { get; set; }
        public string RefNo2 { get; set; }
        public string RefNo3 { get; set; }
        public string OldValueHidden { get; set; }
        public string NewValueHidden { get; set; }
        public string OldValue { get; set; }
        public string NewValue { get; set; }
        public string Reason { get; set; }
        public bool IsAuto { get; set; }
        public string MasterTypeValueSource { get; set; }
        public string TriggerDebugInfo { get; set; }
        public string ChangedBy { get; set; }
        private string _ChangedOn = "";
        public string ChangedOn
        {
            get
            {
                return this._ChangedOn;
            }
            set
            {
                this._ChangedOn = Globals.ConvertDBNulltoNullIfExistsDateTime(value, true) ?? "";
            }
        }
        public string TimeZoneAbbr { get; set; } = "";
    }

    public class P_AuditColumn_Result
    {
        public int rowno { get; set; }
        public int AC_ID { get; set; }
        public string TableName { get; set; }
        public string DbName { get; set; }
        public string Name { get; set; }
        public bool IsPublic { get; set; }


    }
    #endregion AuditHistory
}
