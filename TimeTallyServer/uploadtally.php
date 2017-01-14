<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/12
 * Time: 下午10:52
 */
require_once 'dboperations.php';

$table = 'Tally';
$postJson = getPostJsonValue($table);
$result = uploadTally($table,$postJson);
echo $result;