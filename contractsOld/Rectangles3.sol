// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;//4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

contract Rectangles is ERC721Enumerable, Ownable {

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint256 private pricePerToken = 0.0 ether;//0.01 ether;
    uint256 private maxSupply = 100;
    mapping(uint256 => address) public creators;//dictionaryでクリエーター保存
    mapping(uint256 => TokenData) tokens;//dictionaryでトークンデータ保存
    bool private paused;

    //TokenData構造体
    struct TokenData {
        uint8 x;
        uint8 y;
        uint8 w;
        uint8 h;
        uint8 color;
        uint8 blink;
    }

    Counters.Counter private _tokenIds;

    //コンストラクタ
    constructor() ERC721("64 Rectangles", "RECTS") {
        paused = false;
    }

    //ポーズしてるかどうか判定
    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    //creatorだけ判定
    modifier onlyCreator(uint256 _id) {
        require(
            creators[_id] == msg.sender,
            "64 Rectangles#creatorOnly: ONLY_CREATOR_ALLOWED"
        );
        _;
    }

    //unpauseする（ownerだけ
    function _unpause() public onlyOwner {
        paused = false;
    }

    //pauseする
    function _pause() public onlyOwner {
        paused = true;
    }

    function setTokenData(
        uint256 id,
        uint8 x,
        uint8 y,
        uint8 w,
        uint8 h,
        uint8 color,
        uint8 blink
    ) public onlyCreator(id) {

        //require(x >= 0 && x <= 100, "x is out of range.");
        //require(width > 0 && width <= 100, "Width is out of range.");
        //require(height > 0 && height <= 100, "Height is out of range.");

        tokens[id].x = x;
        tokens[id].y = y;
        tokens[id].w = w;
        tokens[id].h = h;
        tokens[id].color = color;
        tokens[id].blink = blink;
        
    }

    //トークンデータを取得
    function getToken(uint256 id)//getTokenData(uint256 id)
        public
        view
        returns (
            address creator,
            uint8 x,
            uint8 y,
            uint8 h,
            uint8 w,
            uint8 color,
            uint8 blink
        )
    {
        require(
            _exists(id),
            "getTokenData: token query for nonexistent token"
        );
        x = tokens[id].x;
        y = tokens[id].y;
        w = tokens[id].w;
        h = tokens[id].h;
        color = tokens[id].color;
        blink = tokens[id].blink;
        creator = creators[id];
    }

    function getTokens() public view returns (TokenData[] memory){
        uint256 length = totalSupply();
        TokenData[] memory _tokens = new TokenData[](length);
        for (uint256 i = 0; i < length; ++i) {
            _tokens[i] = tokens[i];
        }
        return _tokens;
    }


    function _mintToken(address _to) internal returns (uint256 _tokenId) {
        uint256 tokenId = _tokenIds.current();
        _safeMint(_to, tokenId);
        _tokenIds.increment();
        return tokenId;
    }

    function mint(
        uint8 x,
        uint8 y,
        uint8 w,
        uint8 h,
        uint8 c,
        uint8 b
    ) public payable whenNotPaused {
        require(
            totalSupply() < maxSupply,
            "Maximum supply reached."
        );
        //トランザクションとともに送られたEtherの量
        require(msg.value >= pricePerToken, "Not enough Ether sent.");
        uint256 tokenId = _mintToken(msg.sender);//トークンID
        creators[tokenId] = msg.sender;
        setTokenData(tokenId, x, y, w, h, c, b);
    }

    //オーナーだけミント
    function _mint(
        uint8 x,
        uint8 y,
        uint8 w,
        uint8 h,
        uint8 c,
        uint8 b
    ) public onlyOwner {
        uint256 tokenId = _mintToken(msg.sender);
        creators[tokenId] = msg.sender;
        setTokenData(tokenId, x, y, w, h, c, b);
    }


    //
    function html() private view returns (bytes memory) {
        return
            abi.encodePacked(
                "<!DOCTYPE html>"
                "<html>"
                "<head>"
                "<title>64 Rectangles</title>"
                '<style type="text/css">'
                "body { background:#888;overflow:hidden; } "
                "#container{position:absolute;left:0;top:0;transform-origin: 0 0;} "
                //".rect{  display:flex; align-items:center; justify-content:center; overflow:hidden; position: absolute;animation: anime 1s infinite alternate ease-in-out;} "
                //"@keyframes anime{from {opacity: 0;} to {opacity: 1;}} "
                "</style>"
                "<script>",
                    'window.onload=()=>{'                
                        'resize();'
                        'window.addEventListener("resize",resize);'
                        'function resize(e){'
                            'let s1 = window.innerWidth/100;'
                            'let s2 = window.innerHeight/100;'
                            'document.getElementById("container").style.transform=`scale(${s1},${s2})`;'
                        '}'
                    '}'
                "</script>"
                "</head>"
                "<body>"
                "<div id='container'>",
                    getSVGHeader(),            
                    makeSVG(),
                    '</svg>'                   
                "</div>"
                "</body>"
                "</html>"
            );
    }
    
    //
    function makeSVG() private view returns (bytes memory){

        string memory str = "";
        uint256 supply = totalSupply();

        for (uint256 i = 0; i < supply; ++i) {
            str = string.concat(
                str,
                string( getRect(
                    tokens[i].x,
                    tokens[i].y,
                    tokens[i].w,
                    tokens[i].h,
                    tokens[i].color,
                    tokens[i].blink,
                    tokens[i].x+tokens[i].w/2,
                    tokens[i].y+tokens[i].h/2
                ))                
            );
         }
        
        return abi.encodePacked(str);

    }

    //画像
    function image(uint256 _id) private view returns (bytes memory) {

        return abi.encodePacked(
                getSVGHeader(),
                getRect(
                    tokens[_id].x,
                    tokens[_id].y,
                    tokens[_id].w,
                    tokens[_id].h,
                    tokens[_id].color,
                    tokens[_id].blink,
                    tokens[_id].x+tokens[_id].w/2,
                    tokens[_id].y+tokens[_id].h/2                    
                ),
            '</svg>'
        );
    }

    function getSVGHeader() private pure returns (bytes memory){
        return abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"' 
            ' style="background-color:#888;" width="100px" height="100px">'
            '<style>'
                '.rm{ animation: anim 100ms infinite linear alternate; } '
                'text{ text-anchor: middle; dominant-baseline: central; font-size:3px; font-family: Helvetica, Sans-serif;} '
                '@keyframes anim {0%{ opacity: 0;} 100%{ opacity: 1;}}'
            '</style>'
        );
    }

    function getRect(
        uint8 x,uint8 y,uint8 w,uint8 h,
        uint8 col, uint8 b,uint8 xx2, uint8 yy2
    ) private pure returns (bytes memory)
    {
        uint8 colIdx = col%10;
        uint8 colIdx2 = (col/10);
        
        string memory xx = Strings.toString(x);
        string memory yy = Strings.toString(y);
        string memory ww = Strings.toString(w);
        string memory hh = Strings.toString(h);
        string memory bb = Strings.toString(b);
        
        return abi.encodePacked(
            getRect2(xx,yy,ww,hh),
                ' style="fill:',getHex(colIdx),';" />',
            getRect2(xx,yy,ww,hh),
                ' style="fill:',getHex(colIdx2),';animation-duration:',bb,'0ms;" class="rm" />',
            '<text x="',xx2,'" y="',yy2,'">',xx,'</text>'
        );
    }
    
    function getRect2(
        string memory xx,string memory yy,string memory ww,string memory hh
    ) public pure returns (bytes memory){
        return abi.encodePacked(
            '<rect width="',ww,'"'
                ' height="',hh,'"'
                ' x="',xx,'"'
                ' y="',yy,'"'
        );
    }

    function getHex(uint8 colIdx) public pure returns (string memory) {
        bytes memory colHex = new bytes(0);
        if(colIdx==1) colHex = bytes("#f00");
        else if(colIdx==2) colHex = bytes("#0f0");
        else if(colIdx==3) colHex = bytes("#00f");
        else if(colIdx==4) colHex = bytes("#ff0");
        else if(colIdx==5) colHex = bytes("#f0f");
        else if(colIdx==6) colHex = bytes("#0ff");
        else if(colIdx==7) colHex = bytes("#fff");
        else colHex = bytes("#000");
        return string(colHex);
    }

    //tokenURI
    function tokenURI(uint256 _id) public view override returns (string memory) {
        require(
            _exists(_id),
            "Rectangles: URI query for nonexistent token"
        );
        bytes memory metadata = abi.encodePacked(
            "{"
            '"name":"64 Rectangles #',Strings.toString(_id),'",'
            '"description":"This is a generative art.",',
            '"image":"data:image/svg+xml;base64,',Base64.encode(image(_id)),'",'
            '"external_url": "https://kitasenjudesign.com/rects/",', 
            '"animation_url":"data:text/html;base64,',
            Base64.encode(html()),'",',
            '"attributes": ['               
                '{'
                    '"trait_type": "Width x Height",', 
                    '"value": "',Strings.toString(tokens[_id].w),'x',Strings.toString(tokens[_id].h),'"'
                '},'
            ']'
            "}"
        );

        return string(abi.encodePacked("data:application/json,", metadata));
    }

    //引き出す
    function withdrawAll() external onlyOwner {
        uint256 amount = address(this).balance;
        require(payable(owner()).send(amount));
    }

}