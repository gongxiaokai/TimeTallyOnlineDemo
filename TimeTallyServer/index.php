<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="css/style.css" />
    <title>Document</title>
</head>
<body>

<form id="slick-login" action="useruploadrecords.php" method="get" >
    <input type="text" name="username" placeholder="用户名">
    <input type="password" name="userpsw" placeholder="密码">
    <input type="submit" value="Log In"/>
</form>


</body>
</html>


<?php
/**
// * Created by PhpStorm.
// * User: gongwenkai
// * Date: 2017/1/10
// * Time: 15:37
// */
//require_once 'dboperations.php';
//require_once 'DbModel.php';
////链接数据库
////$con = connectDBandSelect();
////
//////获取post数据
//$postValue = file_get_contents("php://input");
////json解码  (多条数据)
//$jsonPostValue = json_decode($postValue);
////对象临时保存数据
//$obj = new TallyModel();
//$obj->data = 'jjj';
//$obj->typename = '4444';
////echo $obj->typename;
//echo $jsonPostValue->username;
//
////查询多条表数据
////$arr = mysqli_query($con,"SELECT * FROM Tally");
////$num = mysqli_num_rows($arr);
////for ($i=0;$i<$num;$i++){
////    $results[] = mysqli_fetch_assoc($arr);
////    $typename = $results[$i]['flag'];
////    $identity = $results[$i]['identity'];
////    $res[$identity] = $typename;
////}
////echo json_encode($res);


