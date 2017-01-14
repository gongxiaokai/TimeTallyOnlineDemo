

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport"
		  content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<link rel="stylesheet" type="text/css" href="css/tablestyle.css" />
	<title>Document</title>
</head>
<body>
<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/13
 * Time: 16:57
 */
require_once 'dboperations.php';
if (isset($_GET["username"]) && isset($_GET["userpsw"])){
	$username = $_GET["username"];
	$userpsw = $_GET["userpsw"];
}

$verifty = verifyLogin($username,$userpsw);
if ($verifty == 1){
	$table = 'Tally';
    $con = connectDBandSelectTable($table);
	$sql = "SELECT * FROM $table WHERE username = '$username' ORDER BY uploadtime DESC ";
	$res = mysqli_query($con,$sql);


echo "<table>
<tr><th>欢迎用户:$username</th><th></th><th></th><th></th><th></th></tr>
<tr><th>操作记录</th><th>上传时间</th><th>账单类型</th><th>支出</th><th>收入</th></tr>";
	for ($i=0;$i<mysqli_num_rows($res);$i++){
		$resarray = mysqli_fetch_assoc($res);
		$uploadtime = $resarray["uploadtime"];
		$typename = $resarray["typename"];
		$income= $resarray["income"];
		$expenses = $resarray["expenses"];

		?>
		<tr>
			<td>
				<?php echo $i+1?>
			</td>
			<td>
				<?php echo $uploadtime?>
			</td>
			<td>
				<?php echo $typename?>
			</td>
			<td>
				<?php echo $expenses?>
			</td>
			<td>
				<?php echo $income?>
			</td>
		</tr>
<?php
	}
echo "</table>";
}elseif ($verifty == 2){

	echo "<script> alert('密码错误');parent.location.href='index.php'; </script>";

}elseif ($verifty == 3){
	echo "<script> alert('用户不存在');parent.location.href='index.php'; </script>";
}
?>


</body>
</html>
