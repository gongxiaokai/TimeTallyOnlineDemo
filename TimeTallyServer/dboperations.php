<?php
/**
 * Created by PhpStorm.
 * User: gongwenkai
 * Date: 2017/1/10
 * Time: 15:39
 */
require_once 'config.php';

/**链接并选择数据表
 * @param $table 链接表
 * @return mysqli 链接link
 */
function connectDBandSelectTable($table) {
    $con = mysqli_connect(MYSQL_HOST,MYSQL_USER,MYSQL_PSW);
    mysqli_set_charset($con,'utf8');
    if ($con){
        mysqli_select_db($con,MYSQL_DBNAME);
        if(mysqli_num_rows(mysqli_query($con,"SHOW TABLES LIKE '".$table."'"))==0) {
            if ($table == 'Tally'){
                $sql = "CREATE TABLE $table 
                        ( id INT NOT NULL AUTO_INCREMENT , 
                        username VARCHAR(50) NOT NULL ,
                        date VARCHAR(50) NOT NULL , 
                        identity VARCHAR(1024) NOT NULL , 
                        typename VARCHAR(50) NOT NULL , 
                        income DOUBLE NOT NULL , 
                        expenses DOUBLE NOT NULL , 
                        timestamp DOUBLE NOT NULL ,
                        uploadtime TIMESTAMP NOT NULL,
                        PRIMARY KEY (id))";
                mysqli_query($con,$sql);

            }elseif ($table == 'Users'){
                $sql = "CREATE TABLE $table 
                        (id INT  NOT  NULL AUTO_INCREMENT, 
                        username VARCHAR (100) NOT  NULL ,
                        userpsw VARCHAR (100) NOT  NULL , 
                        session INT  NOT  NULL  DEFAULT  0,
                        PRIMARY KEY (id))";
                mysqli_query($con,$sql);
            }
        }
    }
    return $con;
}

/**注册
 * @param $table 表
 * @param $username 用户名
 * @param $userpsw 用户密码
 * @return int 0:连接失败 1:注册成功 2:用户已存在
 */
function register($table,$username,$userpsw){
    $con = connectDBandSelectTable($table);
    if ($con){
        $isExist = existQuery($table,"username",$username);
        if ($isExist == 2){
            $sql = "INSERT INTO $table (username, userpsw) VALUES ('$username',MD5('$userpsw'))";
            $result = mysqli_query($con,$sql);
            if ($result){
                //成功
                return 1;
            }
        }else if ($isExist == 1){
            //已存在
            return 2;
        }
        //关闭数据库
        mysqli_close($con);
    }
    //连接数据库失败
    return 0;
}

/**查询字段是否存在
 * @param $table 表名
 * @param $field 查询字段名
 * @param $obj 查询对象
 * @return 0:连接失败 1:存在 2:不存在
 */
function existQuery($table,$field,$obj){
    $con = connectDBandSelectTable($table);
    if ($con){
        $sql = "SELECT * FROM $table WHERE $field = '$obj'";
        $result = mysqli_query($con,$sql);
        if (mysqli_num_rows($result) > 0){
            return 1;
        }else{
            return 2;
        }
    }
    return 0;
}

/**获取该用户下所有账单
 * @param $table 表名
 * @param $user 用户名
 * @return int|string 0:连接失败或无法查询  string:json数组;
 */
function getUserTally($table,$user){
    $con = connectDBandSelectTable($table);
    if ($con){
        $sql = "SELECT * FROM $table WHERE username = '$user'";
        $arr = mysqli_query($con,$sql);
        $num = mysqli_num_rows($arr);
        if ($num > 0){
            for ($i=0;$i<$num;$i++){
                $results[] = mysqli_fetch_assoc($arr);
            }
            mysqli_close($con);
            return json_encode($results);
        }
    }
    //连接失败或无法查询
    return 0;
}


/**登录验证
 * @param $username 用户名
 * @param $userpsw  用户密码
 * @return int  0:连接失败 1:验证成功 2:密码错误 3:用户不存在
 */
function verifyLogin($username,$userpsw){
    //查询用户名是否存在
    $table = 'Users';
    $con = connectDBandSelectTable($table);
    if ($con){
        $sql = "SELECT * FROM $table WHERE username = '$username'";
        $isExist = mysqli_query($con,$sql);
        if (mysqli_num_rows($isExist) > 0) {
            //存在并继续验证 密码
            $result = mysqli_fetch_array($isExist);
            $psw = $result['userpsw'];
            if (md5($userpsw) == $psw){
                //密码正确
                return 1;
            }else {
                //密码错误
                return 2;
            }

        }else {
            //用户不存在
            return 3;
        }
        mysqli_close($con);
    }

    //数据库连接失败
    return 0;

}

/**上传更新或新增账单数据
 * @param $table  写入表名
 * @param $tallyJson 传入解析后的json
 * @return int -1:数据库连接失败 0:没有写入 1:写入成功 2:写入失败 9:更新数据
 */
function uploadTally($table,$tallyJson){
    $con = connectDBandSelectTable($table);
    $r = 0;
    if ($con){
        //根据json解析出来的数组的长度 更新对应identity数值
        for ($i=0;$i<count($tallyJson);$i++){
            $identity = $tallyJson[$i]->identity;
            $isExistSql = "SELECT * FROM $table WHERE identity LIKE '$identity'";
            $isExisResult = mysqli_query($con,$isExistSql);
            if (mysqli_num_rows($isExisResult) > 0){
                $typename = $tallyJson[$i]->typename;
                $income = $tallyJson[$i]->income;
                $expenses = $tallyJson[$i]->expenses;
                $timestamp = $tallyJson[$i]->timestamp;
                $updateSql = "UPDATE $table 
                          SET typename = '$typename',
                          income='$income' ,
                          expenses = '$expenses',
                          uploadtime = CURRENT_TIMESTAMP,
                          timestamp = '$timestamp'
                          WHERE identity = '$identity'";
                mysqli_query($con,$updateSql);
                $r = 9;
            } else{
                //没有查询到identity则进入新增
                $typename = $tallyJson[$i]->typename;
                $income = $tallyJson[$i]->income;
                $expenses = $tallyJson[$i]->expenses;
                $username = $tallyJson[$i]->username;
                $date = $tallyJson[$i]->date;
                $timestamp = $tallyJson[$i]->timestamp;
                //mysql插入
                $intoSql = "INSERT INTO $table
                          (id,username,date,identity,typename,income,expenses,timestamp,uploadtime)
                          VALUES (NULL, '$username', '$date','$identity','$typename','$income','$expenses','$timestamp',CURRENT_TIMESTAMP)";
                $insertResult = mysqli_query($con,$intoSql);
                if ($insertResult){
                    //新增成功
                   $r = 1;
                }else{
                    //新增失败
                    $r = 2;
                }
            }
        }
    mysqli_close($con);
    }else{
        //连接失败
        $r = -1;
    }
    return $r;
}


/**
 * @param $table 表名
 * @param $identity 需要删除的标识
 * @return int 0:链接数据库失败 1:删除成功 2:删除失败
 */
function deleteTally($table,$identity){
    $con = connectDBandSelectTable($table);
    if ($con){
        $sql = "DELETE FROM $table WHERE identity = '$identity'";
        $result = mysqli_query($con,$sql);
        if ($result){
            return 1;
        }else{
            return 2;
        }
    }
    mysqli_close($con);
    return 0;
}


/**获取post的json数据 并连接数据库表
 * @param $table 表名
 * @return mixed json数据
 */
function getPostJsonValue($table){
//获取post数据
    $postValue = file_get_contents("php://input");
//json解析
    $postJson = json_decode($postValue);
    $currentTable = $table;
//连接并选择数据库
    connectDBandSelectTable($currentTable);
    return $postJson;
}

