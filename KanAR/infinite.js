
function forceReflow()
{
	// normal browser
	// force a reflow to restart animation
	var e,s;
	e=document.querySelector("svg.acjk");
	s=e.innerHTML;
	e.innerHTML="";
	e.innerHTML=s;
}
function getDelay(e)
{
	// normal browser
	var a,m;
	// get css "--d" value
	a=e.getAttributeNS(null,"style");
	if (a&&(m=a.match(/--d:([^;]+);/))) return parseFloat(m[1]);
	return -1;
}
function getDuration(e)
{
	// normal browsers
	return parseFloat(window.getComputedStyle(e,null).getPropertyValue('--t'));
}
function restartAnime()
{
    if (asvg.activated>0) {asvg.run('one'); asvg.run('color');} // pitiful browser
	else forceReflow(); // normal browser
}
function infiniteAnime1(d,t)
{
	// all browsers
	restartAnime();
	setInterval(restartAnime,(d+2*t*1.25)*1000);
}
function infiniteAnime()
{
	// all browsers
	var List,k,km,d,t;
	if (asvg.activated<0) {setTimeout(infiniteAnime,50);return;}
	km=0;
	if (asvg.activated>0) // pitiful browser
	{
		List=document.querySelectorAll("svg.acjk path[class='median']");
		km=List.length;
		if (km)
		{
			d=asvg.getDelay(List[km-1]);
			t=asvg.getDuration(List[km-1]);
		}
	}
	else // normal browser
	{
		List=document.querySelectorAll("svg.acjk path:not([id])");
		km=List.length;
		if (km)
		{
			d=getDelay(List[km-1]);
			t=getDuration(List[km-1]);
		}
	}
	// delay of 1st loop shorter than the following 
	if (km) setTimeout("infiniteAnime1("+d+","+t+")",(d+t*1.25)*1000);
}
window.addEventListener("load",function(){asvg.run('one');asvg.run('color');},false); // pitiful browser
window.addEventListener("load",function(){infiniteAnime();},false); // all browser
