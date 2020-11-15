<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SCA Service</title>
	<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=0a200ee40df01a7833da263a65fbf093"></script>
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
	<script src = "https://code.jquery.com/jquery-3.5.1.min.js"> </script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
	<script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>    
	<script src="resources/js/jquery.twbsPagination.js" type="text/javascript"></script> 
	<link rel="stylesheet" href="resources/css/nav.css">
 <style>

	@import url('https://fonts.googleapis.com/css2?family=Do+Hyeon&display=swap');
	/* font-family: 'Do Hyeon', sans-serif; 쓸 때 이것만 넣어주세요 제목 폰트 */
	@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap');
	/* font-family: 'Noto Sans KR', sans-serif;  쓸 때 이것만 넣어주세요 이건 글 폰트*/

	body{
		font-family: 'Noto Sans KR', sans-serif;
	}

	#map_location{
		margin: 3%;
		width: 1920px;
		height: 700px;
	}
	
	.area {
	    position: absolute;
	    background: #fff;
	    border: 1px solid #888;
	    border-radius: 3px;
	    font-size: 12px;
	    top: -5px;
	    left: 15px;
	    padding:2px;
	}

	
</style>

</head>
<body style=" overflow-x: hidden;">
		<jsp:include page="/WEB-INF/views/navi.jsp"></jsp:include>

	<div id="map_location">
	<strong> <h5>어느 지역의 정보를 알고 싶으신가요? </h5> </strong><br>
		<div id="map" style="width:90%;height:500px;"></div>
	</div>
	
	<jsp:include page="/WEB-INF/views/footer.jsp"></jsp:include>
</body>

<script>
	var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
	    mapOption = { 
	        center: new kakao.maps.LatLng(37.566826, 126.9786567), // 지도의 중심좌표
	        level: 9 // 지도의 확대 레벨
	    };
	
	var map = new kakao.maps.Map(mapContainer, mapOption),
	    customOverlay = new kakao.maps.CustomOverlay({}),
	    infowindow = new kakao.maps.InfoWindow({removable: true});

	$.getJSON("resources/seoul.geojson", function(geojson){		
		var data = geojson.features;
		var coordinates = []; // 좌표 저장할 배열
		var name = '';          // 행정 구 이름
		$.each(data, function(index, val){
			coordinates = val.geometry.coordinates;
			name = val.properties.SIG_KOR_NM;
			displayArea(coordinates, name);
			});		
	});
	
	
	var polygons = []; //
	
	// 행정구역 폴리곤
	function displayArea(coordinates, name){	
		//console.log(name);
		//console.log(coordinates);
		//console.log(coordinates[0][0][0][0]);
		//console.log(coordinates[0][0][0][1]);
		//... 왜 안될까...? 왜 안되지?
		var path = [];
		
		$.each(coordinates[0][0], function(index, coordinate){
			path.push(new kakao.maps.LatLng(coordinate[1],coordinate[0]));
			});
		//console.log("패스요: ", path);
		// 다각형을 생성 
		var polygon = new kakao.maps.Polygon({
			map : map,
			path : path,
			strokeWeight : 2,
			strokeColor : '#004c80',
			strokeOpacity : 0.8,
			fillColor : '#fff',
			fillOpacity : 0.7	
		});
		//console.log("폴리곤이요: ", polygon);
		polygons.push(polygon);
		//console.log("폴리곤스요: ", polygons);
		// 안나오나..?
		
		//--------------이벤트 관련------------------
		// 다각형에  mouseover 이벤트 등록, 발생시 폴리곤 채움색 변경
		// 지역명 표시 커스텀 오버레이 지도위에 표시		
		kakao.maps.event.addListener(polygon, 'mouseover', function(mouseEvent){
			polygon.setOptions({
				fillColor : '#09f'
			});
			customOverlay.setContent('<div class="area">'+name+'</div>');
			customOverlay.setPosition(mouseEvent.latLng);
			customOverlay.setMap(map);				
		});
		
		//다각형에  mousemove 이벤트를 등록, 발생시 커스텀 오버레이 위치 변경
		kakao.maps.event.addListener(polygon, 'mousemove', function(mouseEvent){
			customOverlay.setPosition(mouseEvent.latLng);
		});
		
		//mouseout  이벤트 등록하고 이벤트 발생시 채움색 원래색으로 변경, 커스텀 오버레이 지도에서 제거		
		kakao.maps.event.addListener(polygon, 'mouseout', function(){
			polygon.setOptions({
				fillColor : '#fff'
			});
			customOverlay.setContent('<div class="area">'+name+'</div>');
			customOverlay.setMap(null);
		});
		// 클릭시!! 헣... 끝이다 끝		
	    kakao.maps.event.addListener(polygon, 'click', function(mouseEvent) {
	        /* 이거 의견 물어봐서 마우스 오버 할 때 나오게 할 지 얘기해보기.
	    	var content = '<div class="info">' + 
	                    '   <div class="title">' + name + '</div>' +
	                    '   <div class="size">총 면적 : 약 ' + Math.floor(polygon.getArea()) + ' m<sup>2</sup></area>' +
	                    '</div>';

	        infowindow.setContent(content); 
	        infowindow.setPosition(mouseEvent.latLng); 
	        infowindow.setMap(map);
			*/
	        console.log(name);
	        location.href="whatresult?region="+name;
	        
	    });
		
	}	
	
</script>


</html>