using EBook_Data.Common;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using EBook_Data.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EBook_App.Controllers
{
    public class EBookController : Controller
    {
        #region Controller Constructor
        private IConfiguration _config;
        private IHttpContextAccessor _httpContextAccessor;
        private readonly IADORepository ado;
        private readonly PublicClaimObjects _PublicClaimObjects;
        private readonly string _bodystring = "";
        public EBookController(IConfiguration config, IHttpContextAccessor httpContextAccessor, IADORepository ado)
        {
            this._config = config;
            this._httpContextAccessor = httpContextAccessor;
            this.ado = ado;
            this._PublicClaimObjects = ado.GetPublicClaimObjects();
            this._bodystring = ado.GetRequestBodyString().Result;
        }
        #endregion Controller Constructor

        #region test
        public IActionResult Dashboard()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Get_BestSeller_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponsePageSetup reportResponse = new ReportResponsePageSetup();
            try
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                _ReportParams.PageSize = _ReportParams.PageSize * 4;
                CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                List<P_Department_Result> ResultList = ado.P_Get_Generic_List_SP<P_Department_Result>("P_Get_Department_List", ref List_Dynamic_SP_Params);

                reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));

                //int distributionRatio = Convert.ToInt32(reportResponse.TotalRowCount) / 3;

                List<CardItems> tikList = new List<CardItems>();
                CardItems tik = new CardItems();
                int counter = 1;
                int NewRow = 1;
                foreach (var item in ResultList)
                {
                    P_Department_Result task = new P_Department_Result();
                    task.rowno = NewRow;
                    task.DepartmentName = item.DepartmentName;

                    if (counter == 1)
                    {
                        NewRow += 1;
                        tik.C1 = task;
                    }
                    else if (counter == 2)
                        tik.C2 = task;
                    else if (counter == 3)
                        tik.C3 = task;
                    else if (counter == 4)
                    {
                        tik.C4 = task;
                        tikList.Add(tik);
                        tik = new CardItems();
                    }

                    counter += 1;
                    if (counter > 3)
                        counter = 1;

                    // Increment the counter and reset it after reaching 5
                    //counter = (counter + 1) % Convert.ToInt32(reportResponse.TotalRowCount);
                }

                if (counter <= 3)
                    tikList.Add(tik);

                reportResponse.ResultData = tikList;
                reportResponse.response_code = true;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Get_BestSeller_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        #endregion test

        #region EBook Pages
        public IActionResult Home()
        {
            return View();
        }
        public IActionResult AboutUs()
        {
            return View();
        }
        public IActionResult ContactUs()
        {
            return View();
        }
        public IActionResult Products()
        {
            return View();
        }
        public IActionResult ProductDetail()
        {
            return View();
        }
        public IActionResult Cart()
        {
            return View();
        }
        public IActionResult EmptyCart()
        {
            return View();
        }
        public IActionResult Wishlist()
        {
            return View();
        }
        public IActionResult Checkout()
        {
            return View();
        }
        public IActionResult Profile()
        {
            return View();
        }
        #endregion EBook Pages
    }
}
