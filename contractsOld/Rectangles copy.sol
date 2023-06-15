// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
//import "./Base64.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract Rectangles is ERC721Enumerable, Ownable {

    //using SafeMath for uint256;
    using Counters for Counters.Counter;

    //uint256 private pricePerToken = 0.01 ether;//0.01 ether;
    uint256 private maxSupply = 64;
    mapping(uint256 => address) public creators;//dictionaryでクリエーター保存
    mapping(uint256 => TokenData) tokens;//dictionaryでトークンデータ保存
    bool private paused;
    event MintEvent(address indexed sender);
 
    struct TokenData {
        uint8 x;
        uint8 y;
        uint8 w;
        uint8 h;
        uint8 color;
        uint8 blink;
    }

    Counters.Counter private _tokenIds;

    constructor() ERC721("64 Rectangles", "RECTS") {
        paused = false;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        _;
    }

    modifier onlyCreator(uint256 _id) {
        require(
            creators[_id] == msg.sender || owner() == msg.sender,
            "onlyCreator"
        );
        _;
    }

    function _unpause() public onlyOwner {
        paused = false;
    }

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
        //require(w < 1, "Width is out of range.");
        //require(h < 1, "Height is out of range.");

        tokens[id].x = x;
        tokens[id].y = y;
        tokens[id].w = w;
        tokens[id].h = h;
        tokens[id].color = color;
        tokens[id].blink = blink;
        
    }

    function getTokens(uint256 sIdx, uint256 len) public view returns (TokenData[] memory){
        //uint256 length = totalSupply();
        TokenData[] memory _tokens = new TokenData[](len);
        for (uint256 i = 0; i <len; ++i) {
            _tokens[i] = tokens[sIdx+i];
        }
        return _tokens;
    }

    function getCreators(uint256 sIdx, uint256 len) public view returns (address[] memory){
        address[] memory _creators = new address[](len);
        for (uint256 i = 0; i <len; ++i) {
            _creators[i] = creators[sIdx+i];
        }
        return _creators;
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
            "maxSupply"
        );

        uint256 priceInWei = 0.0 ether;//(10000+4*(w*h)) * 0.000001 ether;
        require(
            msg.value >= priceInWei,
            "notEnoughEth"
        );
        
        uint256 tokenId = _mintToken(msg.sender);//トークンID
        creators[tokenId] = msg.sender;
        setTokenData(tokenId, x, y, w, h, c, b);
        emit MintEvent(msg.sender);
    }

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

    function html() private view returns (bytes memory) {
        return
            abi.encodePacked(
                "<!DOCTYPE html>"
                "<html>"
                "<head>"
                "<title>64 Rectangles</title>"
                '<style>'
                "body { background:#888;overflow:hidden;font-size:30px;font-family:sans-serif; } "
                "#container{position:absolute;left:0;top:0;transform-origin: 0 0;} "
                ".rect{  display:flex; align-items:center; justify-content:center; overflow:hidden; position: absolute;animation: anime 1s infinite alternate ease-in-out;} "
                "@keyframes anime{from {opacity: 0;} to {opacity: 1;}} "
                "</style>"
                "<script>",
                    makeJson(),
                    javascript(),
                "</script>"
                "</head>"
                "<body>"
                "<div id='container'></div>"
                "</body>"
                "</html>"
            );
    }
    
    function javascript() private pure returns (bytes memory) {
        return
            abi.encodePacked(
                'window.onload=()=>{'
                'var cols = ["#000","#f00","#0f0","#00f","#ff0","#f0f","#0ff","#fff"];'
                'var container = document.getElementById("container");'
                'for(let i=0;i<jsons.length;i++){'
                    'let d = jsons[i];'
                    "let dv1 = document.createElement('div');"
                    "let dv2 = document.createElement('div');"
    
                    "let dv1s = dv1.style;"
                    "let dv2s = dv2.style;"
                        'dv1.classList.add("rect");'
                        'dv1.innerText = ""+i;'
                        'dv1s.left  =dv2s.left   =(d[0]*10)+"px";'
                        'dv1s.top   =dv2s.top    =(d[1]*10)+"px";'
                        'dv1s.width =dv2s.width  =(d[2]*10)+"px";'
                        'dv1s.height=dv2s.height =(d[3]*10)+"px";'
                        'dv1s.animationDuration=(d[5])+"0ms";'
                        'dv1s.backgroundColor=cols[Math.floor(d[4]/10)];'
                        'dv1s.zIndex = ""+(i*2);'

                        'dv2s.position = "absolute";'
                        'dv2s.zIndex = ""+(i*2-1);'
                        'dv2s.backgroundColor=cols[d[4]%10];'

                        'container.appendChild(dv1);'
                        'container.appendChild(dv2);'
                '}'

                'rsz();'
                'window.addEventListener("resize",rsz);'
                'function rsz(e){'
                    'let s1 = window.innerWidth/1000;'
                    'let s2 = window.innerHeight/1000;'
                    'container.style.transform=`scale(${s1},${s2})`;'
                '}'

                '}'
            );
    }

    function makeJson() private view returns (bytes memory) {
        bytes memory str = "var jsons=[";
        uint256 supply = totalSupply();
        for (uint256 i = 0; i < supply; ++i) {            
            str = abi.encodePacked(
                    str,
                    "[",
                    Strings.toString(tokens[i].x), ",",
                    Strings.toString(tokens[i].y), ",",
                    Strings.toString(tokens[i].w), ",",
                    Strings.toString(tokens[i].h), ",",
                    Strings.toString(tokens[i].color), ",",
                    Strings.toString(tokens[i].blink),
                    "],"
                );
        }
        return abi.encodePacked(str,"];");
    }

    function image(uint256 _id) private view returns (bytes memory) {

        string memory x = Strings.toString(tokens[_id].x);
        string memory y = Strings.toString(tokens[_id].y);
        string memory w = Strings.toString(tokens[_id].w);
        string memory h = Strings.toString(tokens[_id].h);
        string memory blink = Strings.toString(tokens[_id].blink);
        uint8 col = tokens[_id].color;
        uint8 colIdx = col%10;
        uint8 colIdx2 = (col/10);

        return abi.encodePacked(

            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"' 
            ' style="background-color:#888;">'
                '<style>'
                    '@keyframes anim {0%{ opacity: 0;} 100%{ opacity: 1;}}'
                '</style>'
                '<rect width="',w,'"'
                    ' height="',h,'"'
                    ' x="',x,'"'
                    ' y="',y,'"'
                    ' style="fill:',getHex(colIdx),';" />' 
                '<rect width="',w,'"'
                    ' height="',h,'"'
                    ' x="',x,'"'
                    ' y="',y,'"'
                    ' style="fill:',getHex(colIdx2),';animation: anim ',blink,'0ms infinite linear alternate;" />'
            '</svg>'
        );
    }

    function getHex(uint8 colIdx) public pure returns (bytes memory) {
        bytes memory colHex = new bytes(0);
        if(colIdx==1) colHex = bytes("#f00");
        else if(colIdx==2) colHex = bytes("#0f0");
        else if(colIdx==3) colHex = bytes("#00f");
        else if(colIdx==4) colHex = bytes("#ff0");
        else if(colIdx==5) colHex = bytes("#f0f");
        else if(colIdx==6) colHex = bytes("#0ff");
        else if(colIdx==7) colHex = bytes("#fff");
        else colHex = bytes("#000");
        return colHex;
    }

    function tokenURI(uint256 _id) public view override returns (string memory) {
        require(
            _exists(_id),
            "Rectangles: URI query for nonexistent token"
        );
        bytes memory metadata = abi.encodePacked(
            "{"
            '"name":"Rectangle #',Strings.toString(_id+1),'",'
            '"description":"A generative art made by multiple minters",',
            '"image":"data:image/svg+xml;base64,',Base64.encode(image(_id)),'",'
            '"external_url": "https://kitasenjudesign.com/rects/",', 
            '"animation_url":"data:text/html;base64,',
            Base64.encode(html()),'",',
            '"attributes": ['               
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