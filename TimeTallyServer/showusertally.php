<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/12
 * Time: 17:39
 */
require_once 'dboperations.php';
$table = 'Tally';
$postValue = getPostJsonValue($table);
$reslut = getUserTally($table,$postValue->username);
echo $reslut;
