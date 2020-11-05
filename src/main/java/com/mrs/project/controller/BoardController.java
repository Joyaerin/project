package com.mrs.project.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.mrs.project.dto.BoardDTO;
import com.mrs.project.service.BoardService;


@Controller
public class BoardController {
	
	private Logger logger = LoggerFactory.getLogger(this.getClass());
	
	@Autowired BoardService service;

	/*-----------------------------------공통-----------------------------------------------------------*/
	
	// list.jsp에서 고객센터 또는 자유게시판 버튼에 따라서 목록보기를 부르는 요청(글 리스트불러오기)
	// type -> 0(자유) / 1(고객)
	@RequestMapping(value = "/typelist", method = RequestMethod.GET)
	public ModelAndView list(Model model, @RequestParam String type) {
		logger.info("보드 타입 : "+type);
		ModelAndView mav = new ModelAndView();
		mav.addObject("type",type);
		mav.setViewName("/board/board_list");
		return mav;
	}
	
	
	//아작스 사용해서 페이징한 리스트
	@RequestMapping(value = "/listcall", method = RequestMethod.GET)
	public @ResponseBody HashMap<String, Object> listcall(@RequestParam HashMap<String, String>params) {
		logger.info("보드 타입 : "+params.get("type"));
		logger.info("전체파라미터 : "+params);
		String page = params.get("page");
		String pagePerCnt = params.get("ppn");	
		String type = params.get("type");
		System.out.println(page+"/"+pagePerCnt);
		return service.pagingList(Integer.parseInt(page), Integer.parseInt(pagePerCnt),type);
	}
	
	// writeForm.jsp로만 보내는 요청 -> type에 따라서 달라짐
	@RequestMapping(value = "/writeForm", method = RequestMethod.GET)
	public String writeForm(Model model, HttpSession session, @RequestParam String type) {
		String page = null;
		logger.info("type :"+type);
		if(type.equals("0")) { //자유게시판의 writeForm
		HashMap<String, String> fileList = new HashMap<String, String>();
		session.setAttribute("fileList", fileList);
		page="board/board_write"; 
		model.addAttribute("type",type);
		}else {//고객센터의 writeForm
		page = "board/board_cwrite"; 
		model.addAttribute("type",type);
		}
		return page;
	}
	
	//상세보기 + 업로드한 파일있으면 같이 보이기
	@RequestMapping(value = "/detail", method = RequestMethod.GET)
	public ModelAndView detail(@RequestParam String idx, @RequestParam String type, @RequestParam String pri,HttpSession session,RedirectAttributes rAttr) { 
		logger.info("상세보기 요청"+idx+"/타입:"+type+"/비밀글여부:"+pri);
		ModelAndView mav = null;
		mav = service.detail(idx,type,pri,session,rAttr);
		return mav;
	}
	
	// 게시글 삭제요청
	@RequestMapping(value = "/delete", method = RequestMethod.GET)
	public String delete(Model model, @RequestParam String idx, @RequestParam String type,
			RedirectAttributes rAttr) {
		logger.info("삭제할 idx : "+idx+"타입 : "+type);
		return service.delete(idx,type,rAttr);
	}
	
	//게시판 수정 + 기존파일 삭제했으면 실제 삭제 + 새로올린파일 있으면 실제 저장까지
	@RequestMapping(value = "/update", method = RequestMethod.POST)
	public ModelAndView update(@RequestParam HashMap<String, String> params ,HttpSession session) { //문자열로 파라메터를 보내기 때문에 string으로 받는데 보낼때는 object로 해야함(hashamp, list등으로 반환하기 때문에)
		logger.info("수정요청 요청 글번호 :"+params.get("idx"));	
		logger.info("params : "+params);
		return service.update(params,session);
	}
	
	/*-----------------------------------고객센터 관련------------------------------------------------------*/
	//고객센터의 글쓰기
	@RequestMapping(value = "/cwrite", method = RequestMethod.POST)
	public ModelAndView cwrite(@RequestParam HashMap<String, String> params ,HttpSession session) {
		
		logger.info("글쓰기 요청");	
		logger.info("params : "+params);
		logger.info("비밀글 여부 : "+params.get("privateHidden"));
		if(params.get("privateHidden").equals("")) {
			System.out.println("들어옴?");
			params.put("privateHidden", "0");
			logger.info("비밀글 여부 : "+params.get("privateHidden"));
		}
		return service.cwrite(params,session);
	}
	
	
	/*--------------------------자유게시판 관련-------------------------------------------------------------------------*/

	//자유게시판 안의 파일 업로드를 위해서 창으로 이동
	@RequestMapping(value = "/uploadForm", method = RequestMethod.GET)
	public String uploadForm(Model model) {
		
		return "board/board_photo_uploadForm";
	}
	
	//자유게시판 안의 파일 업로드
	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public ModelAndView upload(MultipartFile file, HttpSession session) {
		logger.info("upload 요청");	
		return service.upload(file,session);
	}
	
	//자유게시판 안의 파일 삭제
	@RequestMapping(value = "/fileDelete", method = RequestMethod.GET)
	public @ResponseBody HashMap<String, Object> fileDelete(@RequestParam String fileName , HttpSession session) {
		logger.info("fileDelete 요청"+fileName);	
		return service.fileDelete(fileName,session);
	}
	
	//업데이트 할 때 자유게시판 안의 파일 삭제
	@RequestMapping(value = "/updateFileDelete", method = RequestMethod.GET)
	public @ResponseBody HashMap<String, Object> updateFileDelete(@RequestParam String fileName , HttpSession session) {
		logger.info("fileDelete 요청"+fileName);	
		return service.updateFileDelete(fileName,session);
	}
	
	//자유게시판의 글쓰기+ 파일업로드 실제 저장
	@RequestMapping(value = "/write", method = RequestMethod.POST)
		public ModelAndView write(@RequestParam HashMap<String, String> params ,HttpSession session) { //문자열로 파라메터를 보내기 때문에 string으로 받는데 보낼때는 object로 해야함(hashamp, list등으로 반환하기 때문에)
			logger.info("글쓰기 요청");	
			logger.info("params : "+params);
			return service.write(params,session);
		}
	
	// 게시판 수정페이지로 이동
	@RequestMapping(value = "/updateForm", method = RequestMethod.GET)
	public ModelAndView updateForm(@RequestParam String idx, @RequestParam String type,HttpSession session) {
		logger.info("받아온 idx : "+idx+"/글 종류 : "+type);
		HashMap<String, String> fileList = new HashMap<String, String>();
		HashMap<String, String> delFileList = new HashMap<String, String>();
		session.setAttribute("fileList", fileList);
		session.setAttribute("delFileList", delFileList);
		return service.updateForm(idx,type,session);
	}
	

	
	//게시판 검색--------------------------------------------------------------------------------------------------------------------------------------------------------
	/*
	@RequestMapping(value = "/opSearch", method = RequestMethod.POST)
	public ModelAndView opSearch(@RequestParam(defaultValue="title") String search_option,@RequestParam(defaultValue="") String keyword) {
		logger.info("검색 요청");	
		logger.info("keyword : "+keyword);
		return  service.listAll(search_option,keyword);
	}
	*/
	
	  @RequestMapping(value = "/opSearch", method = RequestMethod.GET)
	   public ModelAndView opSearch(@RequestParam(defaultValue="title") String search_option,@RequestParam(defaultValue="") String keyword,@RequestParam String type) {
	      System.out.println("여기 오긴오니????");
	      logger.info("검색 요청");   
	      logger.info("option: "+search_option);
	      logger.info("keyword : "+keyword);
	      logger.info("type : "+type);
	      List<BoardDTO> list = service.listSearch(search_option,keyword,type);
	      int count = service.countRecord(search_option,keyword,type);
	      ModelAndView mav = new ModelAndView();
	      Map<String, Object> map = new HashMap<String, Object>();
	      map.put("list", list);
	      map.put("count", count);
	      map.put("search_option", search_option);
	      map.put("keyword",keyword);
	      map.put("type", type);
	      mav.addObject("map",map);
	      mav.addObject("list", list);
	      mav.addObject("count",count);
	      mav.addObject("type",type);
	      mav.setViewName("board/board_resultlist"); 
	      logger.info("listcnt:"+list.size());
	      return mav;
	   }


	/*---------------------------------------------------------------댓글 관련-----------------------------------------------------------------------------------------------------------*/

	//댓글 불러오기
	@RequestMapping(value = "/comlist", method = RequestMethod.GET)
	public @ResponseBody HashMap<String, Object> comlist(@RequestParam HashMap<String, String>params) {
		logger.info("전체파라미터 : "+params);
		String page = params.get("page");
		String pagePerCnt = params.get("ppn");	
		String idx = params.get("idx");
		System.out.println(page+"/"+pagePerCnt);
		return service.comlist(Integer.parseInt(page), Integer.parseInt(pagePerCnt),idx);
	}
	
	//댓글 삭제
	@RequestMapping(value = "/delCom", method = RequestMethod.GET)
	public @ResponseBody HashMap<String, Object> delCom(@RequestParam HashMap<String, String>params) {
		logger.info("전체파라미터 : "+params);
		return service.delCom(params);
	}
	
	//댓글 등록
	@RequestMapping(value = "/insertCom", method = RequestMethod.GET)
	public @ResponseBody HashMap<String, Object> insertCom(@RequestParam HashMap<String, String>params) {
		logger.info("전체파라미터 : "+params);
		return service.insertCom(params);
	}
	
	
}
