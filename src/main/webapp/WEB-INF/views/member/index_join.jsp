<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SCA Service</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Do+Hyeon&display=swap');
/* font-family: 'Do Hyeon', sans-serif; 쓸 때 이것만 넣어주세요 제목 폰트 */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap');
/* font-family: 'Noto Sans KR', sans-serif;  쓸 때 이것만 넣어주세요 이건 글 폰트*/

    .col{
                width: 500px;
                height: 900px;
                position: absolute;
                left: 50%;
                top: 50%;
                transform: translate(-50%,-50%);
                margin: 0 auto;
                font-family: 'Noto Sans KR', sans-serif;
                margin-top: 50px;
            }
    h4{
        color: #4C4C4C;
    }        
    
    input{
        display: inline-block;
        margin-top: 30px;
        width: 270px;
        height: 30px;
        padding: 10px 110px 10px 14px;
        margin: 5px 0 20px 0;
        font-size: 18px;
        border: 0;
        border-bottom:1px solid lightgray;
    }   
    input:focus{
        border-bottom:1px solid #4C4C4C;
        outline: none;
    }
    .btn{
            boeder:1px solid #009fe3;
            color: #009fe3;
            background-color: white;
            padding:13px 180px;
            font-size:17px;
            border-radius:20px;
            cursor: pointer;
            margin-top: 30px;
            }
            
    button:hover {
          opacity: 0.8;
          background-color:#009fe3;
          color: white; 
        }  
</style>
<script src = "https://code.jquery.com/jquery-3.5.1.min.js"> </script>
</head>
<body>
		<div class="col">
		<p style=" font-family: 'Noto Sans KR', sans-serif; font-size: 30px; font-weight: 600; margin-bottom: 30px;">회원가입</p>
	<form action="join" method="post" onsubmit="return joinchk()">
		<div>
		    <h4>아이디</h4>
		    <input type="text" name="user_id" id="user_id"/></br>
		    <span id="idchk"></span>
		</div>
		<div>
		    <h4>비밀번호</h4>
		    <input type="password" name="user_pw"/>
		</div>
		<div>
		    <h4>비밀번호 확인</h4>
		    <input type="password" name="user_pw2" onchange="pwchk()"/></br>
		    <span id="pwchk"></span>
		</div>
		<div>
		    <h4>이  름</h4>
		    <input type="text" name="user_name"/>
		</div>
		<div>
		<h4>이메일</h4>
		<input type="email" name="user_email"/>
		</div>
		<div class="btnbox">
    		<button type="submit" class="btn">가입</button>		
		</div>
	</form>
	</div>
</body>
<script>

	var msg = "${msg}";
	if(msg != ""){
		alert(msg);
		}

	var overid = false;
	
	//아이디 중복확인-------------------------------------------------------------------------------------------------------------------
	$('#user_id').focusout(function() {
		var id = $("input[name='user_id']").val(); 
		console.log(id);
		$.ajax({
				url:'dbchk',
				type:'GET',
				dataType:'JSON',
				data:{"id":id},
				success:function(data){
					//console.log(data.dbchk); // 여기까진 이제 됨 
					if(data.dbchk>0){
						document.getElementById('idchk').innerHTML='아이디가 존재합니다. 다른 아이디를 입력해주세요.'
		                document.getElementById('idchk').style.color='red';
						document.getElementById('user_id').value = null;
						//id.focus;
					}else if(id==""){
						document.getElementById('idchk').innerHTML='아이디를 입력해주세요.'
			            document.getElementById('idchk').style.color='red';
					}
					else{
						document.getElementById('idchk').innerHTML='사용가능한 아이디 입니다.'
						document.getElementById('idchk').style.color='blue';
						overid = true;
					}
				},
				error:function(){
					
				}
			});
		});
	
	//비밀번호 중복확인-----------------------------------------------------------------------------------------------------------------
	
	var overpw = false;
	
	function pwchk(){
		var pw1 = $("input[name='user_pw']").val();
		var pw2 = $("input[name='user_pw2']").val();
		console.log(pw1+"/"+pw2);  
		if(pw1!=pw2){
			document.getElementById('pwchk').innerHTML='비밀번호가 일치하지않습니다. 다시 확인해주세요.'
            document.getElementById('pwchk').style.color='red';
			//console.log("일치하지않음");
		}else{
			document.getElementById('pwchk').innerHTML='비밀번호가 일치합니다.'
            document.getElementById('pwchk').style.color='blue';
			overpw= true;
		}	
	}
	
	function joinchk(){

		if($("input[name='user_id']")!=""){
			if(($("input[name='user_pw']").val()!="") && 
					($("input[name='user_pw2']").val()!="") && 
					($("input[name='user_pw']").val()==$("input[name='user_pw2']").val())){
				if($("input[name='user_name']").val()!=""){
					if($("input[name='user_email']").val()!=""){
						return true;
						}
					}
				}
			}
		console.log("안돼");
		alert("누락된 곳이 있거나 틀린곳이 없는지 확인해주세요.");
		return false;
		}

</script>
</html>