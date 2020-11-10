<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시글 목록</title>
		<style>
			table,th,td{
				border: 1px solid black;
				border-collapse: collapse;
				padding: 10px 10px;
			}
			
			#cominput{
				position : absolute;
				bottom: 46%;
			}
			
		</style>
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
	<script src = "https://code.jquery.com/jquery-3.5.1.min.js"> </script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
	<script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>    
	<script src="resources/js/jquery.twbsPagination.js" type="text/javascript"></script> 
	</head>
	<body>
	<c:import url="../navi.jsp"></c:import> 
	
		<div class="col-md-6" style="position: relative; max-width: 90%; left: 2%; margin-top: 3%; font-size: 15px;">
			<table  class="table table-hover">
				<tr  style="background-color: #0064FF; color: white;">
				<th>작성일</th><td>${info.reg_date}</td>
				<th>작성자</th><td>${info.id}</td>
				<th>조회수</th><td>${info.bHit}</td>
				</tr>
				<tr><th>제목</th><td colspan = "5">${info.subject}</td></tr>
				<tr><th>내용</th><td colspan = "5">${info.content}</td></tr>
			</table>
		 </div> 
			
			<br/>
			
		<div class="col-md-6" style="position: relative; max-width: 90%; left: 2%; margin-top: -1%; font-size: 15px;">
			<table  class="table table-hover">
			<tbody id="comList">
				<!-- 댓글 리스트 출력 -->
			</tbody>
			<tr id="pa">
				<td id="paging" colspan="2"style="text-align: center;height: 63px;">
					<div class="container"   style="position: absolute; left: 40%;">
						<nav arial-label="Page navigation" style="text-align: center">
							<ul class="pagination" id="pagination"></ul>
						</nav>
					</div>
				</td>
			</tr>
		</table>	
	</div>
				<c:choose>
	            <c:when test="${info.board_type eq '1'}"> <!-- 고객센터일때 어드민만 작성가능 -->
	            	<c:if test="${sessionScope.loginid eq 'admin'}">
			            <div id="cominput" style="position: relative;left: 10%; margin-top: 3%;">
							댓글 : <input type="text" value="" id="content" style="width:70%">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="작성" onclick = insert()>	
						</div>
					</c:if>
	            </c:when>
	             <c:when test="${info.board_type eq '0'}"> <!-- 자유게시판일때 --> 
		            <div id="cominput" style="position: relative;left: 5%; margin-top: 3%;">
						댓글 : <input type="text" value="" id="content" style="width:70%">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="작성" onclick = insert()>
					</div>
				</c:when> 
	          </c:choose>  
	          <br/>
		<c:if test="${sessionScope.loginid eq info.id || sessionScope.loginid eq 'admin'}">
			<a href="./delete?idx=${info.board_idx}&type=${info.board_type}">삭제</a>
			<a href="./updateForm?idx=${info.board_idx}&type=${info.board_type}">수정</a>
		</c:if>		

		<c:choose>
		<c:when test="${sessionScope.loginid eq 'admin'}">
			<c:if test="${info.board_type eq '0'}">
				<a href="./admin?page=1">처음으로</a>
			</c:if>
			<c:if test="${info.board_type eq '1'}">
				<a href="./admin_faqboard?page=1">처음으로</a>
			</c:if>
		</c:when>
		
		<c:when test ="${sessionScope.loginid ne 'admin'}">
			<a href="./typelist?type=${info.board_type}">처음으로</a>
		</c:when>
		
		</c:choose>
	</body>
	
	<script>
	
		listCall(1);		
		
		function listCall(page){
			var ppn = 5;
			var idx = "${info.board_idx}";
			$.ajax({
				url: "comlist",
				type:'get',
				data:{
					"ppn":ppn,
					"page":page,
					"idx": idx
				}, 
				dataType :'json',
				success:function(data){

					if(data.allCnt !=0){
						listPrint(data.list);//게시물 그리기
						//플러그인 사용
						$("#pagination").twbsPagination({
							startPage:data.currPage, //시작페이지
							totalPages:data.range, //만들 수 있는 총 페이지 수
							visiblePages: 5, //보여줄 페이지 수 
							onPageClick:function(event,page){ //event : 해당 이벤트 객체 / page : 내가 몇 페이지 클릭 했는지
								listCall(page);
							}
						});
					}else{
						console.log(data.allCnt);
						$("#pa").remove();
						var content ="<th>등록된 댓글이 없습니다.</th>";
						$("#comList").append(content);
					}
				},
				error:function(e){
					console.log(e);
					console.log("실패");
				}
				
			});
		}
		
		var loginId = "${sessionScope.loginid }";
		
		function listPrint(list){ 
			//console.log(list); 
			var content ="";
			
			list.forEach(function(item){
					 content += "<tr>";
					 content += "<input type='hidden' name ='com_idx' value="+item.com_idx+">";
					 content += "<input type='hidden' name ='board_idx' value="+item.board_idx+">";
					 content += "<th style='width: 25px; border-color:black;'>"+item.id+"</th>";
					 var date = new Date(item.com_reg_date);
					 content += "<td style='border-color:black;'>"+item.com_content;
					 content += "    "+date.toLocaleDateString("ko-KR");
					 if(item.id == loginId){
					 	content += " &nbsp &nbsp<input type='button' value='삭제' id='"+item.com_idx+"' onclick=del(this) style='left: 88%;position: absolute;'></td>";
					 } else{
						 content += "</td>";
						  
					 }
					 content += "</tr>";
			});
			$("#comList").empty(); 
			$("#comList").append(content);
			content += "";
		}
		
		function del(d){
			console.log(d.id);
			var idx = d.id;
			var board_idx = "${info.board_idx}";
			$.ajax({
				url: "delCom",
				type:'get',
				data:{
					"idx":idx,
					"board_idx":board_idx
				}, 
				dataType :'json',
				success:function(data){
					console.log("삭제성공");
					var msg = data.msg;
					alert(msg);
					location.reload();
					
				},
				error:function(e){
					console.log(e);
				}
				
			});	
		}
		
		
		function insert(){
			var board_idx = "${info.board_idx}";
			var id = "${sessionScope.loginid}";
			var content = $("#content").val();
			console.log(board_idx+"/"+id+"/"+content);
			
			$.ajax({
				url: "insertCom",
				type:'get',
				data:{
					"idx":board_idx,
					"id":id,
					"content":content
				}, 
				dataType :'json',
				success:function(data){
					console.log("등록");
					var msg = data.msg;
					alert(msg);
					location.reload();
				},
				error:function(e){
					console.log(e);
				}
				
			});	
		}
		
		
		var msg = "${msg}";
		if(msg !=""){
			alert(msg);
		}
		
	</script>
</html>