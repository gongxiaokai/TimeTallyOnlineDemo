<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/12
 * Time: 12:59
 */
require_once 'dboperations.php';
//获取post数据
$table = 'Users';
$postValue = getPostJsonValue($table);
//登录验证
$result = verifyLogin($postValue->username,$postValue->userpsw);
echo $result;
