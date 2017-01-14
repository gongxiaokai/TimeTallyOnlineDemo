<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/12
 * Time: 09:00
 */
require_once 'dboperations.php';
//获取post数据并连接数据库表
$currentTable = 'Users';
$postJson = getPostJsonValue($currentTable);
//注册
$result = register($currentTable,$postJson->username,$postJson->userpsw);
echo $result;
