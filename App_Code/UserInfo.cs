using System;
using System.Collections.Generic;
using System.Web;

/// <summary>
///UserInfo表实体类
/// </summary>
public class UserInfo
{
    private int _uid;
    /// <summary>
    /// 用户UID
    /// </summary>
    public int UID
    {
        get { return _uid; }
        set { _uid = value; }
    }


    private string _userName;
    /// <summary>
    /// 用户名
    /// </summary>
    public string UserName
    {
        get { return _userName; }
        set { _userName = value; }
    }
    private int _deptId;
    /// <summary>
    /// 部门名称
    /// </summary>
    public int DeptId
    {
        get { return _deptId; }
        set { _deptId = value; }
    }
    private int _roleId;
    /// <summary>
    /// 用户角色编号，对应用户权限信息
    /// </summary>
    public int RoleId
    {
        get { return _roleId; }
        set { _roleId = value; }
    }
    //private string _roleName;
    ///// <summary>
    ///// 用户角色名称
    ///// </summary>
    //public string RoleName
    //{
    //    get { return _roleName; }
    //    set { _roleName = value; }
    //}
    public UserInfo()
    {
    }
}