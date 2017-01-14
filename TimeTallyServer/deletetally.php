<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/14
 * Time: 下午3:26
 */
require_once 'dboperations.php';
$table = 'Tally';
$postValue = getPostJsonValue($table);
$reslut = deleteTally($table,$postValue->identity);
echo $reslut;