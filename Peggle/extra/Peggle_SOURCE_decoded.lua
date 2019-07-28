-- /***********************************************
--   Peggle for World of Warcraft
-- /***********************************************

-- Note, projects may have no more than 200 local variables in the declare area.
-- 196 so far!

-- If I need more room, merge functions together (such as the spawn and create functions in the animator)

--[[ Changes
- Added: Version checking. If you are running an older version of Peggle and someone with a newer version is seen on the Battle challenge list, you will be informed that your version is out of date. Out of date Peggle games could result in strange errors.
- Added: Peggle slash command: "/peggle resetwindow" which will center the game on the screen and reset the size of the addon to original starting size.

- Fixed an issue where Unintended Awesome would produce an error message
- Fixed an issue where Battle challenges with more than 7 people being invited might be sent out improperly, corrupting the challenge (resulting in blank names, incorrect scores, and players unable to do the challenge)
- Fixed an issue where Battle challenges with lots of participates could log the user offline while trying to send out the challenge, corrupting the challenge.
- Fixed an issue where, if the user did not start a Peggle Duel or send out a Battle invite, the user would be spammed with "No player named 'xxxx' is online" in certain situations

	window.gameBoardContainer:SetScale(0.5);
	window.artBorder:SetScale(0.5);
	window.catagoryScreen:SetScale(0.5);
	window.logo:SetScale(0.5);
	
--]]

local const = {};
const.versionString = "1.02a";
const.versionID = 1.021;
const.addonName = "PEGGLE";
const.temp = {};
const.seconds = 60;
const.ping = 3;  -- version control. Each version will need this incremented

--const.print = print;
const.debugMode = nil;
local printd = function(...)
	if (const.debugMode) then
		print(...)
	end
end

local levelString = {
	-- Level 1
--	"a`8eo8KB`8bQ8Hf`8fe8Bs`8ck8>k`8e=88Y`8bl83K`8e`8y<`8nV8ND`8qT8Hg`8ol8B4`8rn8<L`8oe88A`8qX838`8n<8yN`8q08t<`84x8i2`86h8n``87v8u1`89o8zy`8;d851`8A985:`8Bn8zI`8Dn8uf`8Dn8nq`8Fq8iM`8Tx8uA`8VB802`8SK84e`8VA88g`8Tr8=v`8Vn8C8`8SM8Ho`8V88Oy`9dY8KL`9gn8FW`9eh8Bk`9gx8=P`9d888I`9fD83H`9dU8x5j9`z8oBNnjj8Xc8nDNnat9cC8qkNnot9fX8rENnot8Tz8nuNmVt8PH8mYNmVt8Mf8mBNmVt8I48mvNmVj8i98oVNm=j8lP8nXNmFt8fo8q4Nm8t8bV8rYNm8t8p98n>NmLt8tk8nrNmLt8wM8mVNmLt8048m?NmLt8iH8v5NmLt8iH81bNmLt8iR86lNmLt8jk8;lNmLt8jk8@lNmLt8jk8FvNmLt8jk8LvNmLt8vu8<bNmLt8va86?NmLt8uR81lNmLt8uH8vSNmLt8148vvNmLt83a8z?NmLt85u83INmLt8I98v>NmVt8GM8zHNmVt8F984kNmVt8O98wkNmVt8O981>NmVt8Op87aNmVt8O98;RNmVt9`p8N>NmVt9`f8H4NmVt9`f8B>NmVt9`f8=kNmVt8ZW88uNmVt8ZC83kNmVt8Z98xHNmV`8>a8;ua8Id8>X`G`c8``8``8s=8eGa8LO8CL`G`c8``8``8s=8eGa87l8;m`G`c8``8``8eG8eGa81z8>P`G`c8``8``8eG8eGa8yc8Dv`G`c8``8``8eG8eGa8DJ8;c`G`c8``8``8s=8eG",
	"43aa`8eo8KB`8bQ8Hf`8fe8Bs`8ck8>k`8e=88Y`8bl83K`8e`8y<`8nV8ND`8qT8Hg`8ol8B4`8rn8<L`8oe88A`8qX838`8n<8yN`8q08t<`84x8i2`86h8n``87v8u1`89o8zy`8;d851`8A985:`8Bn8zI`8Dn8uf`8Dn8nq`8Fq8iM`8Tx8uA`8VB802`8SK84e`8VA88g`8Tr8=v`8Vn8C8`8SM8Ho`8V88Oy`9dY8KL`9gn8FW`9eh8Bk`9gx8=P`9d888I`9fD83H`9dU8x5j9`z8oBNnjj8Xc8nDNnat9cC8qkNnot9fX8rENnot8Tz8nuNmVt8PH8mYNmVt8Mf8mBNmVt8I48mvNmVj8i98oVNm=j8lP8nXNmFt8fo8q4Nm8t8bV8rYNm8t8p98n>NmLt8tk8nrNmLt8wM8mVNmLt8048m?NmLt8iH8v5NmLt8iH81bNmLt8iR86lNmLt8jk8;lNmLt8jk8@lNmLt8jk8FvNmLt8jk8LvNmLt8vu8<bNmLt8va86?NmLt8uR81lNmLt8uH8vSNmLt8148vvNmLt83a8z?NmLt85u83INmLt8I98v>NmVt8GM8zHNmVt8F984kNmVt8O98wkNmVt8O981>NmVt8Op87aNmVt8O98;RNmVt9`p8N>NmVt9`f8H4NmVt9`f8B>NmVt9`f8=kNmVt8ZW88uNmVt8ZC83kNmVt8Z98xHNmV`8>a8;ua8Id8>X`G`c8``8``8s=8eGa8LO8CL`G`c8``8``8s=8eGa87l8;m`G`c8``8``8eG8eGa81z8>P`G`c8``8``8eG8eGa8yc8Dv`G`c8``8``8eG8eGa8DJ8;c`G`c8``8``8s=8eG", -- [1]
	-- Level 2
--	"bj8CF8pfEY=j8C28soEYGj8B?8vqEYQj8As8ygEZ`j8?680DEZjj8=q82SEZtj8C28lWFc=j8:U8qGASQj8:=8tXATbj89<8xdATnj87V8zSATzj8:=8n5AXOj8jr8tNF`Qj8m08zqF`=j8tp8q`AV3j8t=8tqAVrj8u>8wwAVfj8wo8zlAUUj8t=8mHAV?j8o?815F`3j8rl83rF`tj8k=8wCF`Gj8i48qKFa`j8ik8nBFajj8i48k9Fatt80A8hkAWEt84r8hbAWEj87w8hl1Abj8x58h51@Ej8WT8sRAWQj9bU8vuAXnj9`b8tJAXbj8TB8sBAWEj8Q18tfAW9j8XA85LAUlj8Rw84oAU9j8O<827AUE`9bA8G@`8Zu8J2`8U18KN`8SO8GX`8UE8D?`8UR8@=`8Qb8@@`8Nz8=m`8JS8;``8Hs8>E`8D28Ai`8Bv8=g`8CG88H`8FF84Q`8I:80Qj8U085wAUxj9`R85<AU``8YI80h`8VA8wZ`8UE819`8R?8y=`8Kz8xc`8LB8tP`8K28qk`8JS8mv`8Ja8it`8Gc8gm`8O@8jk`8PP8mO`8Or87v`8R38;``8Vv89S`8y:864`81P87D`84O86s`8yF8sf`82<8wN`84O8r<`8dk8wZ`8f3822`8iW851`8eo8Gr`8jh8C2`8mf8IG`8oS8Bm`8rx8G@`8t48B``8qB8=s`8ct8@X`8yF8BF`83r8F0`8618AC`89H8Au`8we8F<",
	"03wbj8CF8pfEY=j8C28soEYGj8B?8vqEYQj8As8ygEZ`j8?680DEZjj8=q82SEZtj8C28lWFc=j8:U8qGASQj8:=8tXATbj89<8xdATnj87V8zSATzj8:=8n5AXOj8jr8tNF`Qj8m08zqF`=j8tp8q`AV3j8t=8tqAVrj8u>8wwAVfj8wo8zlAUUj8t=8mHAV?j8o?815F`3j8rl83rF`tj8k=8wCF`Gj8i48qKFa`j8ik8nBFajj8i48k9Fatt80A8hkAWEt84r8hbAWEj87w8hl1Abj8x58h51@Ej8WT8sRAWQj9bU8vuAXnj9`b8tJAXbj8TB8sBAWEj8Q18tfAW9j8XA85LAUlj8Rw84oAU9j8O<827AUE`9bA8G@`8Zu8J2`8U18KN`8SO8GX`8UE8D?`8UR8@=`8Qb8@@`8Nz8=m`8JS8;``8Hs8>E`8D28Ai`8Bv8=g`8CG88H`8FF84Q`8I:80Qj8U085wAUxj9`R85<AU``8YI80h`8VA8wZ`8UE819`8R?8y=`8Kz8xc`8LB8tP`8K28qk`8JS8mv`8Ja8it`8Gc8gm`8O@8jk`8PP8mO`8Or87v`8R38;``8Vv89S`8y:864`81P87D`84O86s`8yF8sf`82<8wN`84O8r<`8dk8wZ`8f3822`8iW851`8eo8Gr`8jh8C2`8mf8IG`8oS8Bm`8rx8G@`8t48B``8qB8=s`8ct8@X`8yF8BF`83r8F0`8618AC`89H8Au`8we8F<", -- [2]
	-- Level 3
--	"c`8do8x5`8iu8yD`8mp8vm`8fT8t2`8iI8oY`8pb8pr`8pk8jz`86E830`81e83S`80C8yX`8648x=`88W8uU`86v8se`87?8nM`83J8lR`80`8oCj8n;89YNmBj8kj8;kNm9j8h`8<RNm0j8ej8?dNmrt8re895NmKt8uE89eNmKt8yu88ENmKt81U88uNmKj8iH85X9IGj8l885>9I8j8og8499Itj8qv82M9Iej8sl80tNj3j8fW85>9IVj8dx8499Jjj8bi82M9Jyj8tG8xcNjuj8uH8t?Njlj8vn8qbNjct8vg8m0Nj``9`<8IW`8YQ8E:`8ZH8@m`8Ve8?d`8U78C?`8Rv8FA`8Ni8E5`8Lm8AK`8Lj8=o`9e?8xl`9`98y0`8W>8uT`9bx8t<`8Ze8oE`8TL8p1`8TC8je`8Cj830`8I?83S`8IH8zg`8Cz8x=`8Aa8uA`8CB8rB`8B88nz`8FB8lt`8IN8tMj8Vs89ENnej8YD8:RNnnj9aN8<>Nnwj9dD8>KNn5t8RI89lNmWt8Oi88LNmWt8K9881NmWt8GT88aNmWj9`f85D9IGj8Xv85u9IVj8UG84p9Jjj8S88299Jyj8QB80`Nljj9bR85u9I8j9e784p9Itj9gF8299Iej8Pg8wJNlsj8Of8tvNl1j8N@8pINl:t8NG8mgNl=`8IS8oqt8@=8gINktt8<V8gINktt89t8gINktj85B8gINkyj8Do8g?Nkoj82g8gjNk7j8yE8f`Nk@j8GI8g`Nkfj8Kk8eQNjX`8=g83Uj8A68;Rz:jj8@P8>nz:=j8?i8?Uz;`j8<L8@;z;3j8:58?Uz;Qj88I8>nz<tj88h8;Rz<Gj88I89:z=jj8:587Nz==j8<L87mz>`j8?i87Nz>3j8@P89:z>Q`8ka8IW`8lG8E:`8kP8@m`8p88?d`8qf8C?`8tr8FA`8x48E5`8z08AK`8z38=o`8f88Jh`9ea8I5j8bC8ACNmij9gj8AzNn>`80r8ut",
	"u3wc`8do8x5`8iu8yD`8mp8vm`8fT8t2`8iI8oY`8pb8pr`8pk8jz`86E830`81e83S`80C8yX`8648x=`88W8uU`86v8se`87?8nM`83J8lR`80`8oCj8n;89YNmBj8kj8;kNm9j8h`8<RNm0j8ej8?dNmrt8re895NmKt8uE89eNmKt8yu88ENmKt81U88uNmKj8iH85X9IGj8l885>9I8j8og8499Itj8qv82M9Iej8sl80tNj3j8fW85>9IVj8dx8499Jjj8bi82M9Jyj8tG8xcNjuj8uH8t?Njlj8vn8qbNjct8vg8m0Nj``9`<8IW`8YQ8E:`8ZH8@m`8Ve8?d`8U78C?`8Rv8FA`8Ni8E5`8Lm8AK`8Lj8=o`9e?8xl`9`98y0`8W>8uT`9bx8t<`8Ze8oE`8TL8p1`8TC8je`8Cj830`8I?83S`8IH8zg`8Cz8x=`8Aa8uA`8CB8rB`8B88nz`8FB8lt`8IN8tMj8Vs89ENnej8YD8:RNnnj9aN8<>Nnwj9dD8>KNn5t8RI89lNmWt8Oi88LNmWt8K9881NmWt8GT88aNmWj9`f85D9IGj8Xv85u9IVj8UG84p9Jjj8S88299Jyj8QB80`Nljj9bR85u9I8j9e784p9Itj9gF8299Iej8Pg8wJNlsj8Of8tvNl1j8N@8pINl:t8NG8mgNl=`8IS8oqt8@=8gINktt8<V8gINktt89t8gINktj85B8gINkyj8Do8g?Nkoj82g8gjNk7j8yE8f`Nk@j8GI8g`Nkfj8Kk8eQNjX`8=g83Uj8A68;Rz:jj8@P8>nz:=j8?i8?Uz;`j8<L8@;z;3j8:58?Uz;Qj88I8>nz<tj88h8;Rz<Gj88I89:z=jj8:587Nz==j8<L87mz>`j8?i87Nz>3j8@P89:z>Q`8ka8IW`8lG8E:`8kP8@m`8p88?d`8qf8C?`8tr8FA`8x48E5`8z08AK`8z38=o`8f88Jh`9ea8I5j8bC8ACNmij9gj8AzNn>`80r8ut", -- [3]
	-- Level 4
--	"d`8de8?@`8hc8AV`8l18?e`8rK8Gs`8vA8@k`8xr88S`80e82u`8Be82u`8CZ89O`8H`8Ae`8L38GE`8R78<J`8V:8?R`8ZV8Ax`9ee8?x`8N?84H`8Oi80E`8NQ8vX`8Y083U`9b:8yE`8dH8z8`8hr84R`8og85r`8nY81ot8U=8uXNkot8Yn8uANkot9aO8uuNkot9e58tYNkot8U`8q0Nket8X98p4Nket9ab8o8Nket9d;8n<Nket8iG8vgNkyt8fg8uKNkyt8b58u4Nkyt8jt8q:Nk8t8fJ8p>Nk8t8cs8oBNk8`8nE8wBt8sM8q>Nket8wv8pBNket8zN8oFNket83w8nJNket8y=8tXNkjt8Cj8uNNkyt8?:8u7Nkyt8;S8ukNkyt8;F8n8Nk5t8?r8orNk5t8BN8paNk5t8Fz8pKNk5t8IV8q:Nk5t82k8tvNkjj8O@8n4x<hj8MM8lp5Ggj8978gpNmQj85S8gyNmLj82v8gLNmHj8yL8h7NmCj8vw8i5Nm?j8rW8jFNm:j8=e8gyNmUj8@B8gLNmZj8Dl8h7Nncj8GA8i5Nnhj8K`8jFNnlj8nr8n8x:lj8pf8lw5Fcj9`X89p5CPj9cB88m5C<j9eO86t5Csj8Yd89s5Dij8Vw88w5D2j8Tf8695DFj8jC8:W5CPj8my89T5C<j8gJ8:Z5Dij8ec8:c5D2j8bM88p5DFj8R68E6=Pbj8Pf8BZ=Pjj8Nd8@o=Pqj8L18=m=Pyj8Kj89Y=P5j8Jw86A=P=j8Jf83n=Sjj8Ul8G?=OUj8Ir8zP=Sbj8kJ8E6=NOj8nj8BZ=NGj8pl8@o=N@j8qO8=m=N8j8sf89Y=N1j8sT86A=Ntj8tj83n=PQj8id8G?=NWj8tY8zP=PYa86986j`G?T7Z87Z`8``8a3a86i883`G1@7Zk7Z=8``8bja8698:G`Gnw7Zk7Z38``8a3",
	"t;Id`8de8?@`8hc8AV`8l18?e`8rK8Gs`8vA8@k`8xr88S`80e82u`8Be82u`8CZ89O`8H`8Ae`8L38GE`8R78<J`8V:8?R`8ZV8Ax`9ee8?x`8N?84H`8Oi80E`8NQ8vX`8Y083U`9b:8yE`8dH8z8`8hr84R`8og85r`8nY81ot8U=8uXNkot8Yn8uANkot9aO8uuNkot9e58tYNkot8U`8q0Nket8X98p4Nket9ab8o8Nket9d;8n<Nket8iG8vgNkyt8fg8uKNkyt8b58u4Nkyt8jt8q:Nk8t8fJ8p>Nk8t8cs8oBNk8`8nE8wBt8sM8q>Nket8wv8pBNket8zN8oFNket83w8nJNket8y=8tXNkjt8Cj8uNNkyt8?:8u7Nkyt8;S8ukNkyt8;F8n8Nk5t8?r8orNk5t8BN8paNk5t8Fz8pKNk5t8IV8q:Nk5t82k8tvNkjj8O@8n4x<hj8MM8lp5Ggj8978gpNmQj85S8gyNmLj82v8gLNmHj8yL8h7NmCj8vw8i5Nm?j8rW8jFNm:j8=e8gyNmUj8@B8gLNmZj8Dl8h7Nncj8GA8i5Nnhj8K`8jFNnlj8nr8n8x:lj8pf8lw5Fcj9`X89p5CPj9cB88m5C<j9eO86t5Csj8Yd89s5Dij8Vw88w5D2j8Tf8695DFj8jC8:W5CPj8my89T5C<j8gJ8:Z5Dij8ec8:c5D2j8bM88p5DFj8R68E6=Pbj8Pf8BZ=Pjj8Nd8@o=Pqj8L18=m=Pyj8Kj89Y=P5j8Jw86A=P=j8Jf83n=Sjj8Ul8G?=OUj8Ir8zP=Sbj8kJ8E6=NOj8nj8BZ=NGj8pl8@o=N@j8qO8=m=N8j8sf89Y=N1j8sT86A=Ntj8tj83n=PQj8id8G?=NWj8tY8zP=PYa86986j`G?T7Z87Z`8``8a3a86i883`G1@7Zk7Z=8``8bja8698:G`Gnw7Zk7Z38``8a3", -- [4]
	-- Level 5
--	"ej8=r8mNAWGj8@88njAWSj8C?8okAXdj8F38pLAXpj8HP8rYAX1j8JJ8u@AX=j8Lf8x>AXIj8LK80LAXUj8:`8njAW;j86T8okAWzj84e8pLAWnj81C8rYAWbj8zI8u@AVQj8RT8sJJi`j8Ts8vBJiij8Um8yHJirj8U?81UJi0j8U:85hJdzj8Ql8qbJhVj8Or8n5JhRj8Mj8lcJhMj8JO8iMJhIj8Hz8gIJhDj9a:88;EYCj9aG851EY>j9aA82rFcCj9as8ziFc>j9`B8wcFc9j8ZJ8tbFc4j8Y?8qgFczj8Xn8ntFcuj8V<8k?Fcpj8TE8ieFckj8R?8fGFcft8gS8Bu=Sjt8gq8>F=Sjt8f?8;g=Sjt8eX878=Sjt8ev83T=Sjt8dD80u=Sjt8db8wF=Sjt8c08tg=Sjt8ob8I4=Slt8s587k=Smt8s`83:=Smt8r;8zT=Smt8rf8ws=Smt8qA8sB=Smt8sT8:K=Smt8tx8>0=Smt8tL8B`=Smt8n98EO=Slt8n`8Bo=Slt8m78>?=Slt8lY8:Z=Slt8l587z=Slt8kW83J=Slt8k380j=Slt8jU8w:=Slt8j18sU=Slt8iS8pu=Sl`8dA8K4`8gb8Gs`8kI8Ni`8oh8Qo`8rG8RG`8sN8Jg`8ym8Ib`8uN8F8`8yN8;4`80H8?A`8458B5`88L8D5`8E>8FJ`8Jk8JU`8MU8MR`8QX8Pt`8V:8Qp`9aF8Li`8XC8IO`8Ul8F6`8Rf8B4`8WS8?e`9`A8Dd`9d:8Gk`9eR8;G`9fE84m`9fa8w0`9cH8pM`8HY8mH`8CR8iZ`8<G8hn`86:8i;`80R8l8`8vy8nh`8xh8hH`8s`8iN`8k68k2`85>8xw`8<b8y;`8BA8vG`8HW85M`8JE8;c`8HN8>t`8DK83B`8@e84m`8;885D`87o86g`9a68le",
	"wi<ej8=r8mNAWGj8@88njAWSj8C?8okAXdj8F38pLAXpj8HP8rYAX1j8JJ8u@AX=j8Lf8x>AXIj8LK80LAXUj8:`8njAW;j86T8okAWzj84e8pLAWnj81C8rYAWbj8zI8u@AVQj8RT8sJJi`j8Ts8vBJiij8Um8yHJirj8U?81UJi0j8U:85hJdzj8Ql8qbJhVj8Or8n5JhRj8Mj8lcJhMj8JO8iMJhIj8Hz8gIJhDj9a:88;EYCj9aG851EY>j9aA82rFcCj9as8ziFc>j9`B8wcFc9j8ZJ8tbFc4j8Y?8qgFczj8Xn8ntFcuj8V<8k?Fcpj8TE8ieFckj8R?8fGFcft8gS8Bu=Sjt8gq8>F=Sjt8f?8;g=Sjt8eX878=Sjt8ev83T=Sjt8dD80u=Sjt8db8wF=Sjt8c08tg=Sjt8ob8I4=Slt8s587k=Smt8s`83:=Smt8r;8zT=Smt8rf8ws=Smt8qA8sB=Smt8sT8:K=Smt8tx8>0=Smt8tL8B`=Smt8n98EO=Slt8n`8Bo=Slt8m78>?=Slt8lY8:Z=Slt8l587z=Slt8kW83J=Slt8k380j=Slt8jU8w:=Slt8j18sU=Slt8iS8pu=Sl`8dA8K4`8gb8Gs`8kI8Ni`8oh8Qo`8rG8RG`8sN8Jg`8ym8Ib`8uN8F8`8yN8;4`80H8?A`8458B5`88L8D5`8E>8FJ`8Jk8JU`8MU8MR`8QX8Pt`8V:8Qp`9aF8Li`8XC8IO`8Ul8F6`8Rf8B4`8WS8?e`9`A8Dd`9d:8Gk`9eR8;G`9fE84m`9fa8w0`9cH8pM`8HY8mH`8CR8iZ`8<G8hn`86:8i;`80R8l8`8vy8nh`8xh8hH`8s`8iN`8k68k2`85>8xw`8<b8y;`8BA8vG`8HW85M`8JE8;c`8HN8>t`8DK83B`8@e84m`8;885D`87o86g`9a68le", -- [5]
	-- Level 6
--	"fo8Wj8G39H3a3`c8k38k38``8``o8Wj8G39HQa3d@8k38k38``8``o8Wj8G39Ita3i68k38k38``8``o8Wj8G39IGa3nc8k38k38``8``o8Wj8G39Jja3rT8k38k38``8``o8Wj8G39J=a3wJ8k38k38``8``o8Wj8G39K`a31w8k38k38``8``o8Wj8G39K3a36m8k38k38``8``o8Wj8G39KQa3;c8k38k38``8``o8Wj8G39Lta3?@8k38k38``8``o8Wj8G39LGa3D68k38k38``8``o8Wj8G39Mja3Iw8k38k38``8``j88F82O5DSj8n;8mDJhBj8qg8o@JhFj8s78qIJhKj8uG8teJhOj8wI8v<JhTj8y=8ynJhXj80n80YJibj81>83RJifj8Hn8xa5CLj8JN8vL5C8j8LQ8tI5Coj8Ny8qYATej8El8xr5Dej8B08w95Dyj8>e8sxAVej8@a8uQ5DBj8Ob8nKASZj8Oz8k9ASTj8Oz8hrAXX`9f=82B`9bQ8yE`9f48vn`9`C8tQa8SG8j=aj`c8``8``8lQ8nta8SG8lQaj`c8``8``8lQ8nta8VG8y`aj`c8``8``8;=8nta8VG803aj`c8``8``8;=8nt`8E580W`8AE80P`8>h827`8;A8zv`8:v8wa`88E8sx`86b8o4`82Y8kh`8yL8gx`8ir8re`8mE8tC`8q:8xk`8tY80C`8w<84N`8ra841`8nN81P`8j482>`8fL840`8b>82S`8l`8:e`8lr8>e`8kQ8AR`8kG8Fd`8kG8IE`80n8IH`8x?8Gj`8ua8FI`8tR8Ck`8tM8?8`8uA8;A`8@38h``8A=8mG`8CQ8rt`8H38qG`8Jj8mj`8JG8g3`8hl8Kvj8::85h5D>j8@q875Nk2`8Ms82x`8I481j`8P980cj8;z8iWAVwj8;j8fEAV2j8;V8mkAVqj8<O8ptAVkj8=g86>5Dtj8CN87SNkxj8G288bNktj8K`87SNkoj8N=875Nkkj8QM8695CGj8tA8gEJhEj8we8iJJhIj8yy8laJhNj8058n5JhRj8278qqNnCj84z8ttNnGj86a8w7NnLj8718zMNnPj8Tu85d5C3",
	"z;7fo8Wj8G39H3a3`c8k38k38``8``o8Wj8G39HQa3d@8k38k38``8``o8Wj8G39Ita3i68k38k38``8``o8Wj8G39IGa3nc8k38k38``8``o8Wj8G39Jja3rT8k38k38``8``o8Wj8G39J=a3wJ8k38k38``8``o8Wj8G39K`a31w8k38k38``8``o8Wj8G39K3a36m8k38k38``8``o8Wj8G39KQa3;c8k38k38``8``o8Wj8G39Lta3?@8k38k38``8``o8Wj8G39LGa3D68k38k38``8``o8Wj8G39Mja3Iw8k38k38``8``j88F82O5DSj8n;8mDJhBj8qg8o@JhFj8s78qIJhKj8uG8teJhOj8wI8v<JhTj8y=8ynJhXj80n80YJibj81>83RJifj8Hn8xa5CLj8JN8vL5C8j8LQ8tI5Coj8Ny8qYATej8El8xr5Dej8B08w95Dyj8>e8sxAVej8@a8uQ5DBj8Ob8nKASZj8Oz8k9ASTj8Oz8hrAXX`9f=82B`9bQ8yE`9f48vn`9`C8tQa8SG8j=aj`c8``8``8lQ8nta8SG8lQaj`c8``8``8lQ8nta8VG8y`aj`c8``8``8;=8nta8VG803aj`c8``8``8;=8nt`8E580W`8AE80P`8>h827`8;A8zv`8:v8wa`88E8sx`86b8o4`82Y8kh`8yL8gx`8ir8re`8mE8tC`8q:8xk`8tY80C`8w<84N`8ra841`8nN81P`8j482>`8fL840`8b>82S`8l`8:e`8lr8>e`8kQ8AR`8kG8Fd`8kG8IE`80n8IH`8x?8Gj`8ua8FI`8tR8Ck`8tM8?8`8uA8;A`8@38h``8A=8mG`8CQ8rt`8H38qG`8Jj8mj`8JG8g3`8hl8Kvj8::85h5D>j8@q875Nk2`8Ms82x`8I481j`8P980cj8;z8iWAVwj8;j8fEAV2j8;V8mkAVqj8<O8ptAVkj8=g86>5Dtj8CN87SNkxj8G288bNktj8K`87SNkoj8N=875Nkkj8QM8695CGj8tA8gEJhEj8we8iJJhIj8yy8laJhNj8058n5JhRj8278qqNnCj84z8ttNnGj86a8w7NnLj8718zMNnPj8Tu85d5C3", -- [6]
	-- Level 7
--	"gw8Bq8xh1@S`G?T8``8``8``8``w8FY8zz1A=`GH68``8``8``8``w8Hj83Y1=h`G`c8``8``8``8``w8ET88b1=M`GfT8``8``8``8``w8=;87L1>O`GvT8``8``8``8``w8;>8321?9`G1@8``8``8``8``w8=L8yJ1@n`G7w8``8``8``8``w8AD8921@S`Gnw8``8``8``8```8Bl83Kb8Bl83Kbj`c8k38k38``8``b8Bl83Kbjgm8k38k38``8``b8Bl83Kbjnw8k38k38``8``b8Bl83Kbju68k38k38``8``b8Bl83Kbj1@8k38k38``8``b8Bl83Kbj8J8k38k38``8``b8Bl83Kbj?T8k38k38``8``b8Bl83KbjGc8k38k38``8```80x8AA`85c8AK`89I8AA`8Kp8Bb`8O18Bc`8Sl8Bj`8W@8E:`8r58Fn`8hL8Jz`8g=8EM`8gb8@O`8j:8>``8qh8=d`8vU8<:`8wj88y`8vS82Z`8wa8y;`8vA8tb`8q085V`8my88A`8gY87t`8c;8;4`8bH839`8gj8yN`8dh8uM`8gb8rj`8kn8vP`8l;82F`8qh8zx`8pc8vl`8la8qe`8nb8k<`8s;8kt`8ua8fv`8u38oQ`8608m=`86k8sf`8QX8sS`8Sb8x?`8Ww8xR`8Xs82P`8X`88o`8Ww8<r`8Z38?o`9cd8BF`9bq8FR`9cm8Lh`9eR8>1`9f;8:z`9aY87a`9eR82F`9b08yN`9dV8sy`8Uv8iW`8Wn8fv`8EI8ku`8FW8gq`8@x8hd`8AE8kEj85u8eU1@Sj82S8fw1@;j80Q8gF1@nj8z<8iL1?Qj8zo8ln1?9j87D8f81Apj89?8ha1A=j8:I8jl1AUj8:U8l@1=hj8QG8ml1@Sj8Ou8m>1@;j8Ms8nX1@nj8KY8qc1?Qj8Tf8mJ1Apj8Va8os1A=j8Wk8q31AUj8Ww8sR1=h",
	"zlqgw8Bq8xh1@S`G?T8``8``8``8``w8FY8zz1A=`GH68``8``8``8``w8Hj83Y1=h`G`c8``8``8``8``w8ET88b1=M`GfT8``8``8``8``w8=;87L1>O`GvT8``8``8``8``w8;>8321?9`G1@8``8``8``8``w8=L8yJ1@n`G7w8``8``8``8``w8AD8921@S`Gnw8``8``8``8```8Bl83Kb8Bl83Kbj`c8k38k38``8``b8Bl83Kbjgm8k38k38``8``b8Bl83Kbjnw8k38k38``8``b8Bl83Kbju68k38k38``8``b8Bl83Kbj1@8k38k38``8``b8Bl83Kbj8J8k38k38``8``b8Bl83Kbj?T8k38k38``8``b8Bl83KbjGc8k38k38``8```80x8AA`85c8AK`89I8AA`8Kp8Bb`8O18Bc`8Sl8Bj`8W@8E:`8r58Fn`8hL8Jz`8g=8EM`8gb8@O`8j:8>``8qh8=d`8vU8<:`8wj88y`8vS82Z`8wa8y;`8vA8tb`8q085V`8my88A`8gY87t`8c;8;4`8bH839`8gj8yN`8dh8uM`8gb8rj`8kn8vP`8l;82F`8qh8zx`8pc8vl`8la8qe`8nb8k<`8s;8kt`8ua8fv`8u38oQ`8608m=`86k8sf`8QX8sS`8Sb8x?`8Ww8xR`8Xs82P`8X`88o`8Ww8<r`8Z38?o`9cd8BF`9bq8FR`9cm8Lh`9eR8>1`9f;8:z`9aY87a`9eR82F`9b08yN`9dV8sy`8Uv8iW`8Wn8fv`8EI8ku`8FW8gq`8@x8hd`8AE8kEj85u8eU1@Sj82S8fw1@;j80Q8gF1@nj8z<8iL1?Qj8zo8ln1?9j87D8f81Apj89?8ha1A=j8:I8jl1AUj8:U8l@1=hj8QG8ml1@Sj8Ou8m>1@;j8Ms8nX1@nj8KY8qc1?Qj8Tf8mJ1Apj8Va8os1A=j8Wk8q31AUj8Ww8sR1=h", -- [7]
	-- Level 8
--	"hj8@l8waJdtj8@c8sMJiyj8?C8p?Jiuj8@c8zoJdxj8?C822Jd2j8?b85<Jd6j8>k88CJd;j8=c8;DJd?j8;F8>>JdDj8:i8A0JdHj88x8DdJdMj86y8F>JdQj84m8HWJdVj81N8KhJdZj8zu8LOx8tj8wB8LFx8Vj8uz8JOJftj8s18HtJfxj8qA8E?Jf2j8pf8BKJf6j8nK8?PJf;j8mE8<OJf?j8lP89HJfDj8lq86tNl4j8kN82GNl8j8kD8zhNl=t8kN8v:NlAt8ld8rSNlAt8lu8oqNlAj89e8shNj`j88V8o9Noej88V8vFNjdj8888zsNjij87M82MNjmj86O86rNjrj85>89ANjvj8qq8rENl=j8q08ofNlBj8q08vsNl9j8qN8yPNl4j8r982zNl0j8s685ONlvj8tH89nNlrj8Ek8:7Njvj8Fz87gNjqj8Gv83ANjmj8CD8=JNjzj8b=8wsNl=j8bF8zQNl8j8ci833Nl4j8cO86XNlzj8dM8:2Nlvj8fc8=LNlqj8g<8AcNlmj8iv8DmNlhj8kv8GlNldj8m:8J`NkZj8oY8LANkVj8r@8OeNkQj8u38QuNkMj8bF8sDNlAj8ci8pgNlFj8QA8xE1=Ej8O98yU1>bj8Me8zk1>zj8JI8y21>Gj8HU8wK1?dj8Sd8vF1=xt8EN8qB1?ot8Gx8tW1?ot8SO8sI1=ot8TJ8po1=oj9`p8K2JhUj8Yp8HSJhPj8Wd8F:JhLj8T@8D4JhCj8QR8BJJh:j8NT8A:Jh1j8KL8@LJhsj9aT8NjJicj8M88:BNmZj8Qa8;xNncj8T68<vNnhj8WQ8=<Nnlj9`h8?dNnqj9cr8@NNnuj9fq8BNNnz`8VC87;`8Qt83U`8XS822`9dr802`9`08w9`9f386R`8J48pP`8MW8uE`8PK8pF`8zo8q@`8wC8vv`82u8vZ`8z781q`8vr8?I`8z58Ei`8348@kj8AX8@UNj3j8@a8CWNj8",
	"0v8hj8@l8waJdtj8@c8sMJiyj8?C8p?Jiuj8@c8zoJdxj8?C822Jd2j8?b85<Jd6j8>k88CJd;j8=c8;DJd?j8;F8>>JdDj8:i8A0JdHj88x8DdJdMj86y8F>JdQj84m8HWJdVj81N8KhJdZj8zu8LOx8tj8wB8LFx8Vj8uz8JOJftj8s18HtJfxj8qA8E?Jf2j8pf8BKJf6j8nK8?PJf;j8mE8<OJf?j8lP89HJfDj8lq86tNl4j8kN82GNl8j8kD8zhNl=t8kN8v:NlAt8ld8rSNlAt8lu8oqNlAj89e8shNj`j88V8o9Noej88V8vFNjdj8888zsNjij87M82MNjmj86O86rNjrj85>89ANjvj8qq8rENl=j8q08ofNlBj8q08vsNl9j8qN8yPNl4j8r982zNl0j8s685ONlvj8tH89nNlrj8Ek8:7Njvj8Fz87gNjqj8Gv83ANjmj8CD8=JNjzj8b=8wsNl=j8bF8zQNl8j8ci833Nl4j8cO86XNlzj8dM8:2Nlvj8fc8=LNlqj8g<8AcNlmj8iv8DmNlhj8kv8GlNldj8m:8J`NkZj8oY8LANkVj8r@8OeNkQj8u38QuNkMj8bF8sDNlAj8ci8pgNlFj8QA8xE1=Ej8O98yU1>bj8Me8zk1>zj8JI8y21>Gj8HU8wK1?dj8Sd8vF1=xt8EN8qB1?ot8Gx8tW1?ot8SO8sI1=ot8TJ8po1=oj9`p8K2JhUj8Yp8HSJhPj8Wd8F:JhLj8T@8D4JhCj8QR8BJJh:j8NT8A:Jh1j8KL8@LJhsj9aT8NjJicj8M88:BNmZj8Qa8;xNncj8T68<vNnhj8WQ8=<Nnlj9`h8?dNnqj9cr8@NNnuj9fq8BNNnz`8VC87;`8Qt83U`8XS822`9dr802`9`08w9`9f386R`8J48pP`8MW8uE`8PK8pF`8zo8q@`8wC8vv`82u8vZ`8z781q`8vr8?I`8z58Ei`8348@kj8AX8@UNj3j8@a8CWNj8", -- [8]
	-- Level 9
--	"ij8728xm1A`j87y8341A`t84z8xi1@Lt8:s8yq1Aot8==8zK1Aot8@R81u1Aot8Dl82O1Aot8G684y1Aot8JK85S1Aot8Ne8721Aot8Qz88W1Aot8TD8:61Aot8WY8<`1Aot9`s8=:1Aot9c=8?d1Aot8:s84:1Aot8==86d1Aot8@R87>1Aot8Dl89h1Aot8G68:B1Aot8JK8<l1Aot8Ne8=F1Aot8Qz8?p1Aot8TD8@J1Aot8WY8Bt1Aot9`s8CN1Aot9c=8Ex1Aot80D8x21@Lt8468351@Lt80N83K1@Lt8m88lwx<vt8n`8oVx<vt8n88s:x<vt8o`8wix<vt8o88zHx<vt8p`83wx<vt8p886Vx<vt8q`8::x<vt8q88>ix<vt8r`8AHx<vt8lZ8hGx<vt8se8k@x<vt8s=8oox<vt8te8rNx<vt8t=8v2x<vt8ue8zax<vt8u=82@x<vt8ve86ox<vt8v=89Nx<vt8we8=2x<vt8w=8Aax<vt8r<8h`x<vt8xQ8FHx<gt8s68GHx7uj8EV8oq5D`j8Ce8nH5Dtj8@=8mt5D=j8>G8ke5DQj8=H8hy5Ejj8HK8nH5CGj8Ks8mt5C3j8Mi8ke5Cjj8Nh8hy5BQ`8308fL`8ze8fV`8yz8mq`80m8s5`8458rT`84Y8lJ`8<i8sA`8@48se`8?o8wr`8F78wl`8Jq8ub`8N:8vf`8Rb8tn`8Vd8rZ`8V58vK`8UV8op`8Vw8l1`8ZK8te`9cV8v7`9aM8yG`8YO812`9`Y85I`9eb83X`8Qe80s`8Lg8zI`8N083z`9dQ8L3`8Zj8IQ`8T38Gt`8NG8DG`8I`8Bj`8Ct8?=`8==8=``87Q8:3`81=89=`8gG8>i`8bR8=5`8eO88R`8b?845`8id85D`8eW81p`8c`8xo`8gv8tY`8kO8:n`8jm8zrt8zs8Jex<gt8s18Kyx7u",
	"5LPij8728xm1A`j87y8341A`t84z8xi1@Lt8:s8yq1Aot8==8zK1Aot8@R81u1Aot8Dl82O1Aot8G684y1Aot8JK85S1Aot8Ne8721Aot8Qz88W1Aot8TD8:61Aot8WY8<`1Aot9`s8=:1Aot9c=8?d1Aot8:s84:1Aot8==86d1Aot8@R87>1Aot8Dl89h1Aot8G68:B1Aot8JK8<l1Aot8Ne8=F1Aot8Qz8?p1Aot8TD8@J1Aot8WY8Bt1Aot9`s8CN1Aot9c=8Ex1Aot80D8x21@Lt8468351@Lt80N83K1@Lt8m88lwx<vt8n`8oVx<vt8n88s:x<vt8o`8wix<vt8o88zHx<vt8p`83wx<vt8p886Vx<vt8q`8::x<vt8q88>ix<vt8r`8AHx<vt8lZ8hGx<vt8se8k@x<vt8s=8oox<vt8te8rNx<vt8t=8v2x<vt8ue8zax<vt8u=82@x<vt8ve86ox<vt8v=89Nx<vt8we8=2x<vt8w=8Aax<vt8r<8h`x<vt8xQ8FHx<gt8s68GHx7uj8EV8oq5D`j8Ce8nH5Dtj8@=8mt5D=j8>G8ke5DQj8=H8hy5Ejj8HK8nH5CGj8Ks8mt5C3j8Mi8ke5Cjj8Nh8hy5BQ`8308fL`8ze8fV`8yz8mq`80m8s5`8458rT`84Y8lJ`8<i8sA`8@48se`8?o8wr`8F78wl`8Jq8ub`8N:8vf`8Rb8tn`8Vd8rZ`8V58vK`8UV8op`8Vw8l1`8ZK8te`9cV8v7`9aM8yG`8YO812`9`Y85I`9eb83X`8Qe80s`8Lg8zI`8N083z`9dQ8L3`8Zj8IQ`8T38Gt`8NG8DG`8I`8Bj`8Ct8?=`8==8=``87Q8:3`81=89=`8gG8>i`8bR8=5`8eO88R`8b?845`8id85D`8eW81p`8c`8xo`8gv8tY`8kO8:n`8jm8zrt8zs8Jex<gt8s18Kyx7u", -- [9]
	-- Level 10
--	"jj9bC8uXNmQj8H98rzNmZj8@L8?UFajj8Ae8<KFatj8AS89IFa3j8Co86SFa=j8E`84vFaGj8Go82gFaQj8IN80tFb`j8LC8yXFbjj8Js8=IFaGj8L78;:FaQj8Oe89GFb`j8QU880Fbjj8TX87=Fbtj8Xf87tFb3j9`o87=Fb=j8H58@vFa=j8Gj8CkFa3j8Cp8gKEZ=j8@m8h=EZGj8=d8hQEZQj89V8h=F``j8Fe8f4EZ3j86S8gJF`jj84c8f3F`t`8N58Fe`8R48A5`8X<8>:`9cA8>6`9eO83Qb8Vo8zO`Q`c8bj8bQ8``8``b8Vo8zO`Qnw8bj8bQ8``8``b8Vo8zO`Q1@8bj8bQ8``8``b8Vo8zO`Q?T8bj8bQ8``8```8Oo84``8Je87y`8FV8;L`8=`86j`89=82G`8@382G`8=`8rt`8BG8x``87t8x`b8nr8z5`Q`c8bj8bQ8``8``b8nr8z5`Qnw8bj8bQ8``8``b8nr8z5`Q1@8bj8bQ8``8``b8nr8z5`Q?T8bj8bQ8``8```8sp8jS`8Dh8nh`8Ja8mP`8O18ng`8Uv8n:`8ZO8o>`9eZ8qe`8Rl8jHj8Rf8r9NmZj8U=8sxNnhj9fp8vpNmZj8DV8rfNmQj8gc8uXNmQj81m8rzNmHj88V8?UEY=j88B8<KFc=j87Q89IFc3j86886SFctj84G84vFcjj82882gFc`j8zT80tFbQj8xc8yXFbGj8z58=IFcjj8xq8;:Fc`j8uB89GFbQj8rM880FbGj8oJ87=Fb=j8l@87tFb3j8i887=Fbtj81r8@vFctj82=8CkFc3`8vr8Fe`8rr8A5`8lk8>:`8ff8>6`8cT83Q`8u884``8zB87y`82L8;L`85@8nh`8zE8mO`8uv8nf`8o18n9`8iR8o>`8cH8qej8r@8r9NmHj8oj8swNm?j8c68vpNmHj84L8rfNmQ",
	":Atjj9bC8uXNmQj8H98rzNmZj8@L8?UFajj8Ae8<KFatj8AS89IFa3j8Co86SFa=j8E`84vFaGj8Go82gFaQj8IN80tFb`j8LC8yXFbjj8Js8=IFaGj8L78;:FaQj8Oe89GFb`j8QU880Fbjj8TX87=Fbtj8Xf87tFb3j9`o87=Fb=j8H58@vFa=j8Gj8CkFa3j8Cp8gKEZ=j8@m8h=EZGj8=d8hQEZQj89V8h=F``j8Fe8f4EZ3j86S8gJF`jj84c8f3F`t`8N58Fe`8R48A5`8X<8>:`9cA8>6`9eO83Qb8Vo8zO`Q`c8bj8bQ8``8``b8Vo8zO`Qnw8bj8bQ8``8``b8Vo8zO`Q1@8bj8bQ8``8``b8Vo8zO`Q?T8bj8bQ8``8```8Oo84``8Je87y`8FV8;L`8=`86j`89=82G`8@382G`8=`8rt`8BG8x``87t8x`b8nr8z5`Q`c8bj8bQ8``8``b8nr8z5`Qnw8bj8bQ8``8``b8nr8z5`Q1@8bj8bQ8``8``b8nr8z5`Q?T8bj8bQ8``8```8sp8jS`8Dh8nh`8Ja8mP`8O18ng`8Uv8n:`8ZO8o>`9eZ8qe`8Rl8jHj8Rf8r9NmZj8U=8sxNnhj9fp8vpNmZj8DV8rfNmQj8gc8uXNmQj81m8rzNmHj88V8?UEY=j88B8<KFc=j87Q89IFc3j86886SFctj84G84vFcjj82882gFc`j8zT80tFbQj8xc8yXFbGj8z58=IFcjj8xq8;:Fc`j8uB89GFbQj8rM880FbGj8oJ87=Fb=j8l@87tFb3j8i887=Fbtj81r8@vFctj82=8CkFc3`8vr8Fe`8rr8A5`8lk8>:`8ff8>6`8cT83Q`8u884``8zB87y`82L8;L`85@8nh`8zE8mO`8uv8nf`8o18n9`8iR8o>`8cH8qej8r@8r9NmHj8oj8swNm?j8c68vpNmHj84L8rfNmQ", -- [10]
	-- Level 11
--	"kj8kn8B8z:=j8i78Dnz;`j8gj8DOz;3j8dM8Dnz;Qj8cg8B8z<tj8b68@kz<Gj8lq8@az=jj8mW8>uz==j8pt8=Dz>`j8rA8>uz>3j8tw8@az>Qj8uu8Bvz<tj8vL8Dqz<ej8xG8EIz;Qj8zY8FDz;Bj8208G`z;3j8Pg8>@z:=j8N08@vz;`j8Lc8@Wz;3j8IF8@vz;Qj8GI8>?9LOj8Ev8=l9L@j8BA8<29L1j8Qc8<oz=jj8RI8:8z==j8Uf89Sz>`j8WI8:`5D`j8Z>89:5CGj9bf88g5C3j9cQ85S5Cjj9dP83l5BQj9dP80t5GGj8o:8qrNj`j8oq8mDNoaj8n18jlNnSj8mb8fQNnJj8oq8tONjij80N8prNl=j81g8lDNlFj81V8ilNlOj83v8eQNlXj81g8sONl4j8@a8ihNlyj8?o8e?Nl2j8Ae8l;Nltj8B18oSNlpj8Dg8sbNlgj8Fu8uSNkYj8HT8xyNkPj8K=8zg1>Bj8MX8zB1>uj8Py8zl1=Xj8Ry8xK1=@j8Ta8vM1@oj8Vd8u91@<j8X78uf1@Tj8ZS8u41>yj9bv8uj1>aj9d28sR1=Dj9eN8qR1=wa8jr8M?bj`c8``8``8f38dta8qV8LVbji68``8``8f38dta8pQ8HJbjrT8``8``8f38dta8ut8Ibbj1w8``8``8f38dta8GN8FPbj`c7Z`7Z38f38dta8OI8DEbjfw7Z`7Z38f38dta8N18Jnbjl@7Z`7Z38f38dta8U08@VbjrT7Z`7Z38f38dta8XR8Gkbjym7YQ7Y`8f38dta9bQ8Awbj4J7Z`7Z38f38dta9eq8GKbj;c7Y37Zj8f38dt`8eX8;o`8dt86d`8mc8:0`8u38:K`8r@82Z`8rx870`8zr8:S`8yW8?3`83L8>D`8EY877`8L58:F`8MH85t`8Sv868`8XC85k`8ZQ80U`8Be8B?`8vl8sv`8uP8mF`8tZ8gP`8h;8t<`8cC8po`8gU8lba8jm8Ivbj;c8``8``8f38dta8cI8LtbjD68``8``8f38dta8T28K5bjAw7Z`7Z38f38dta8Y@8K=bjG@7Vj7X38f38dt`8B`83F`8zb86i`8>f8;h`8=C8Ad",
	";@?kj8kn8B8z:=j8i78Dnz;`j8gj8DOz;3j8dM8Dnz;Qj8cg8B8z<tj8b68@kz<Gj8lq8@az=jj8mW8>uz==j8pt8=Dz>`j8rA8>uz>3j8tw8@az>Qj8uu8Bvz<tj8vL8Dqz<ej8xG8EIz;Qj8zY8FDz;Bj8208G`z;3j8Pg8>@z:=j8N08@vz;`j8Lc8@Wz;3j8IF8@vz;Qj8GI8>?9LOj8Ev8=l9L@j8BA8<29L1j8Qc8<oz=jj8RI8:8z==j8Uf89Sz>`j8WI8:`5D`j8Z>89:5CGj9bf88g5C3j9cQ85S5Cjj9dP83l5BQj9dP80t5GGj8o:8qrNj`j8oq8mDNoaj8n18jlNnSj8mb8fQNnJj8oq8tONjij80N8prNl=j81g8lDNlFj81V8ilNlOj83v8eQNlXj81g8sONl4j8@a8ihNlyj8?o8e?Nl2j8Ae8l;Nltj8B18oSNlpj8Dg8sbNlgj8Fu8uSNkYj8HT8xyNkPj8K=8zg1>Bj8MX8zB1>uj8Py8zl1=Xj8Ry8xK1=@j8Ta8vM1@oj8Vd8u91@<j8X78uf1@Tj8ZS8u41>yj9bv8uj1>aj9d28sR1=Dj9eN8qR1=wa8jr8M?bj`c8``8``8f38dta8qV8LVbji68``8``8f38dta8pQ8HJbjrT8``8``8f38dta8ut8Ibbj1w8``8``8f38dta8GN8FPbj`c7Z`7Z38f38dta8OI8DEbjfw7Z`7Z38f38dta8N18Jnbjl@7Z`7Z38f38dta8U08@VbjrT7Z`7Z38f38dta8XR8Gkbjym7YQ7Y`8f38dta9bQ8Awbj4J7Z`7Z38f38dta9eq8GKbj;c7Y37Zj8f38dt`8eX8;o`8dt86d`8mc8:0`8u38:K`8r@82Z`8rx870`8zr8:S`8yW8?3`83L8>D`8EY877`8L58:F`8MH85t`8Sv868`8XC85k`8ZQ80U`8Be8B?`8vl8sv`8uP8mF`8tZ8gP`8h;8t<`8cC8po`8gU8lba8jm8Ivbj;c8``8``8f38dta8cI8LtbjD68``8``8f38dta8T28K5bjAw7Z`7Z38f38dta8Y@8K=bjG@7Vj7X38f38dt`8B`83F`8zb86i`8>f8;h`8=C8Ad", -- [11]
	-- Level 12
--	"lj8Hi8nD=N=j8Fb8q1=NLj8Cu8s7=O`j8@i8tM=Ooj8<G8ur=O3j89v8tM=OBj8318q1=Pej8z082DNj`j8zg8zfNoaj8yr8v>NnSj8wS8ssNnJj8v`8poNnAj8sD8m7Nn8j8pW8kjNnzj8mS8isNnqj8j<8gTNnhj8ge8gdNmZj8HJ83DNl=j8Ic80fNlFj8IS8w>NlOj8Kr8trNlXj8Mj8qoNmfj8O68n7Nmoj8Rm8ljNmxj8Ur8jsNm6j8X>8hTNm?j9ae8hdNmHj8En8gG5BGj8DE8j<5C`j8Cq8md5Ctj8Ab8nU5C=j8>v8oT5CQj8;38oT5Djj88G8nU5D3j8688md5DGj85d8j<5E`j84<8gG5Etj8<E86zz;3j8?a85Iz;`j8@H84bz:=j8Ay81Ez:jj8:x85Iz;Qj88A84bz<tj88`81Ez<G`8RL8xk`9cB8xG`8WE820`8V@8pK`9dg8uF`8Rd81q`8QW85p`8QP8:f`8OP8>0`8M<8BR`9b281Z`9`x867`9`F8:G`9aL8>?`9c68AQ`8Sc8ty`9bW8q2`9`v8m``8rH8xa`8fR8x=`8mO82q`8nT8pA`8f28u<`8s581g`8s=85f`8sD89W`8uE8>q`8wY8BH`8hg81P`8jl86x`8iN8:=`8hH8>5`8gd8AG`8r68to`8g=8qs`8jn8lQ`80R89h`8G589j`88t8?i`8@88?;`8<881y`89J8i``8?J8i``84f8wO`8DU8xy`8oe8Ah`8pw8G``8VL8@E`8U:8F=j8zQ8k8NnKj86i8s7=OQj81u8nC=Ptj8yb8h1NnBj8vI8e@Nn9j8IA8kyNlWj8K58hrNmej8MI8e5Nmn`8<N8eI",
	"8ellj8Hi8nD=N=j8Fb8q1=NLj8Cu8s7=O`j8@i8tM=Ooj8<G8ur=O3j89v8tM=OBj8318q1=Pej8z082DNj`j8zg8zfNoaj8yr8v>NnSj8wS8ssNnJj8v`8poNnAj8sD8m7Nn8j8pW8kjNnzj8mS8isNnqj8j<8gTNnhj8ge8gdNmZj8HJ83DNl=j8Ic80fNlFj8IS8w>NlOj8Kr8trNlXj8Mj8qoNmfj8O68n7Nmoj8Rm8ljNmxj8Ur8jsNm6j8X>8hTNm?j9ae8hdNmHj8En8gG5BGj8DE8j<5C`j8Cq8md5Ctj8Ab8nU5C=j8>v8oT5CQj8;38oT5Djj88G8nU5D3j8688md5DGj85d8j<5E`j84<8gG5Etj8<E86zz;3j8?a85Iz;`j8@H84bz:=j8Ay81Ez:jj8:x85Iz;Qj88A84bz<tj88`81Ez<G`8RL8xk`9cB8xG`8WE820`8V@8pK`9dg8uF`8Rd81q`8QW85p`8QP8:f`8OP8>0`8M<8BR`9b281Z`9`x867`9`F8:G`9aL8>?`9c68AQ`8Sc8ty`9bW8q2`9`v8m``8rH8xa`8fR8x=`8mO82q`8nT8pA`8f28u<`8s581g`8s=85f`8sD89W`8uE8>q`8wY8BH`8hg81P`8jl86x`8iN8:=`8hH8>5`8gd8AG`8r68to`8g=8qs`8jn8lQ`80R89h`8G589j`88t8?i`8@88?;`8<881y`89J8i``8?J8i``84f8wO`8DU8xy`8oe8Ah`8pw8G``8VL8@E`8U:8F=j8zQ8k8NnKj86i8s7=OQj81u8nC=Ptj8yb8h1NnBj8vI8e@Nn9j8IA8kyNlWj8K58hrNmej8MI8e5Nmn`8<N8eI", -- [12]
	-- Game variables data (Base70 to prevent cheaters from cheating, a little...)
	"";
};

const.GetBackdrop = function ()
	return {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = 1,
		edgeSize = 16,
		insets = {
			top = 5,
			right = 5,
			left = 5,
			bottom = 5,
		}
	}
end

const.locale = {
	["ABOUT"] = "ABOUT",
	["ABOUT_TEXT1"] = "The Peggle Institute has opened a branch in Azeroth!\n\n" ..

			"After we successfully brought the Bejeweled experience into " ..
			"WoW, the PopCap Guild decided to tackle another of our favorite things: Peggle.\n\n" ..

			"We wanted something more competitive that we could use to settle " ..
			"loot disputes and challenge each other while we waited for that " ..
			"last raid member to log on. We've packed in some great touches " ..
			"for the add-on version of Peggle, and now it's ready to be shared with the world!",

	["ABOUT_TEXT2"] = "For more great games check out |cFFFF66CChttp://popcap.com|r\n" .. "All our WoW Addons are officially hosted at |cFFFF66CChttp://popcap.com/wow",
	["ABOUT_TEXT3"] = "(C) 2007, 2009 PopCap Games, Inc. All rights reserved.",
	["ABOUT_TEXT4"] = "Version ",

	["_BALL_SCORE"] = "+10,000",
	["BALLS_LEFT1"] = "%d BALLS LEFT",
	["BALLS_LEFT2"] = "LAST BALL!",
	["BEAT_THIS_LEVEL1"] = "Beat this level to earn\n+1 talent point!",
	["BEAT_THIS_LEVEL2"] = "Clear all pegs to earn\n+1 talent point!",
	["BEAT_THIS_LEVEL3"] = "+1 talent point earned\n(Beat level)",
	["BEAT_THIS_LEVEL4"] = "+1 talent point earned\n(Full clear)",
	["BRAG"] = "What channel would you like to brag to?",

	["CHALLENGE"] = "BATTLE",
--	["CHALLENGE_CUR_WINNER"] = "Current Winner:",
	["CHALLENGE_DETAILS"] = "BATTLE DETAIL",
	["CHALLENGE_DESC"] = "Select a battle to view its details\nor create a new battle",
	["CHALLENGE_DESC1"] = "Click a name to quickly add/remove it!",
	["CHALLENGE_DESC2"] = "|cFFFF8C00CHAT CHANNELS: Adding a custom chat channel will invite all in the chat channel at the time of battle creation. This will not invite offline users, nor users who do not have the addon installed.\n\nYou may only invite custom channels.",
	["CHALLENGE_DESC3"] = "Note: Offline users will not receive the battle until they come online while another invitee or you are also online.",
	["CHALLENGE_CAT1"] = "From:",
	["CHALLENGE_CAT2"] = "Level:",
	["CHALLENGE_CAT3"] = "Shots:",
	["CHALLENGE_CAT4"] = "Current Standing:",
	["CHALLENGE_CAT5"] = "Time Left:",
	["CHALLENGE_CAT6"] = "Note to Players:",
	["CHALLENGE_LIST"] = "Battle List",
	["CHALLENGE_DETAILS"] = "Battle Details",
	["CHALLENGE_DUR"] = "BATTLE DURATION",
	["CHALLENGE_GUILD1"] = "View Offline Guild Members",
	["CHALLENGE_GUILD2"] = "Sort by Online Status",
	["CHALLENGE_INVITE1"] = "|cFFFF8C00FRIENDS",
	["CHALLENGE_INVITE2"] = "|cFFFF8C00GUILD",
	["CHALLENGE_INVITE3"] = "|cFFFF8C00CHANNEL",
	["CHALLENGE_LIMIT"] = "Limit of 5 Active\nBattles at once",
	["CHALLENGE_NEW"] = "NEW BATTLE",
	["CHALLENGE_NONE"] = "NO BATTLE SELECTED",
	["CHALLENGE_RANK"] = "%d of %d",
--	["CHALLENGE_PLAYER"] = "PLAYER DETAILS",
	["CHALLENGE_SHOTS"] = "NUMBER OF SHOTS",
	["CHALLENGE_SORT_ONLINE"] = "Sort by Online Status",
	["CHALLENGE_REPLAYS"] = "NUMBER OF REPLAYS",
	["CHALLENGE_VIEW_OFFLINE"] = "View Offline Guild Members",
	["CHALLENGE_YOUR_STATUS"] = "Your Status:",

	["CHAR_SELECT"] = "CHARACTER SELECT",
	["CREDITS"] = "CREDITS",
	["CREDITS1"] = "Programmer",
	["CREDITS1a"] = "Michael Fromwiller",
	["CREDITS2"] = "Producer",
	["CREDITS2a"] = "T. Carl Kwoh",
	["CREDITS3"] = "Artists",
	["CREDITS3a"] = "Tysen Henderson\n" .. "Noah Maas",
	["CREDITS4"] = "Level Design",
	["CREDITS4a"] = "Stephen Notley",
	["CREDITS5"] = "Quality Assurance",
	["CREDITS5a"] = "Ed Miller\n" .. "Eric Olson",
	["CREDITS6"] = "Peggle Credits",
	["CREDITS6a"] = "Sukhbir Sidhu\n" .. "Brian Rothstein\n" .. "Eric Tams\n" .. "Jeremy Bilas\n" .. "Walter Wilson\n" .. "Matthew Holmberg",
	["CREDITS7"] = "Special Thanks",
	["CREDITS7a"] = "Jason Kapalka\n" .. "Dave Haas\n" .. "Blizzard Entertainment\n" .. "Jen Chess\n" .. "Scott Lantz\n" .. "Anthony Coleman",
	["CREDITS8"] = "Beta Testers",
	["CREDITS8a"] = "BraveOne - Aerie Peak [A]\n" .. "Johndoe - Executus EU [A]\n" .. "Kinu - Ravencrest [H]\n" .. "Klauen - Blackrock [H]\n" .. "Lothaer - Spinebreaker [A]\n" .. "Naiad - Dalaran [A]",
	["CREDITS8b"] = "Palasadia - Doomhammer [H]\n" .. "Polgarra - Terokkar [A]\n" .. "Smashtastic - Khadgar [A]\n" .. "Sythalin - Thunderlord[A]\n" .. "Thanotos- Turalyon[A]\n" .. "Vodax - Dalaran [A]\n" .. "Zoquara - Nordrassil [A]",

--"BraveOne - Aerie Peak [A]\n" .. "Johnd�e - Executus EU [A]\n" .. "Kinu - Ravencrest [H]\n" .. "Klauen - Blackrock [H]\n" .. "Lothaer - Spinebreaker [A]\n" .. "Naiad - Dalaran [A]",
--"Palasadia - Doomhammer [H]\n" .. "Polgarra - Terokkar [A]\n" .. "Smashtastic - Khadgar [A]\n" .. "Sythalin - Thunderlord[A]\n" .. "Thanotos- Turalyon[A]\n" .. "Zoquara - Nordrassil [A]",

	["DUEL"] = "DUEL",
	["DUEL_BREAKDOWN1"] = "Your Score: %s",
	["DUEL_BREAKDOWN1a"] = "Opponent's Score: %s",
	["DUEL_BREAKDOWN2"] = "Talent: |cFFFFFFFF%s",
	["DUEL_BREAKDOWN3"] = "Style: |cFFFFFFFF%s",
	["DUEL_BREAKDOWN4"] = "Fever: |cFFFFFFFF%s",
	["DUEL_CHALLENGE"] = "%s has challenged you to a duel!",
	["DUEL_FORFEIT1"] = "|cFFFF0000You forfeited the duel!",
	["DUEL_FORFEIT2"] = "|cFFFF0000Opponent forfeited the duel!",
	["_DUEL_HISTORY"] = "Last 10 opponents:",
	["_DUEL_NO_HISTORY"] = "No one has been dueled!",
	["DUEL_OPP_WL"] = "Win/Loss vs %s: %d - %d",
	["DUEL_RESULTS"] = "DUEL RESULTS",
	["DUEL_RESULT1"] = "WAITING ON\n%s",
	["DUEL_RESULT2"] = "|cFF00FF00DEFEATED\n%s",
	["DUEL_RESULT3"] = "|cFFFF0000DEFEATED BY\n%s",
	["DUEL_RESULT4"] = "|cFFFF0000DUEL WAS\nFORFEITED",
	["DUEL_SCORE1"] = "Your Score: %s",
	["DUEL_SCORE2"] = "Opponent Score: %s",
	["DUEL_STATUS"] = "DUEL INVITE STATUS",
	["DUEL_STATUS1"] = "Sending duel invite...",
	["DUEL_STATUS2"] = "Waiting for user to accept duel request...",
	["DUEL_STATUS3"] = "User declined the duel request.",
	["DUEL_STATUS4"] = "User does not have Peggle addon turned on.",
	["DUEL_STATUS5"] = "User is currently being challenged. Try again in a few minutes.",
	["DUEL_STATUS6"] = "Challenger cancelled the duel.",
	["DUEL_TIME"] = "Duel time remaining: %s",
	["DUEL_TOTAL_WL"] = "Total Win/Loss: %d - %d",
	["DUEL_WAITING"] = "Your opponent is still playing...",

	["_EXPIRED"] = "Expired",
	["FORFEIT"] = "Forfeit",
	["_FREE_BALL"]	= "FREE BALL!",
	["FREE_BALL2"] = "FREE\nBALL",
	["_FREE_BALL_DUEL"] = "BUCKET BONUS\n%s",
	["GENERATING_NAMES"] = "Generating name list for custom channels...",
	["HOW_TO_PLAY1"] = "Basic Gameplay",
	["HOW_TO_PLAY2"] = "Duel Mode",
	["HOW_TO_PLAY2a"] = "Duel Mode lets you challenge another player to a 1-on-1 ten-ball " ..
			    "game of Peggle. Choose a level and type in the name of the player " ..
			    "you want to challenge, then hit Play!\n\n" .. 
			    
			    "Players must be online and have the add-on in order to participate, " ..
			    "and if they are already in another duel you won't be able to challenge " ..
			    "them until they are finished.\n\n" ..
 
			    "Duel mode stores your last ten opponents as a handy drop-down so you can " ..
			    "quickly get a rematch.",
	["HOW_TO_PLAY2b"] = "After each duel, the summary screen shows how you fared vs your opponent " ..
			    "and gives a breakdown of the point scoring. It also displays which character " ..
			    "your opponent used, as well as how many levels they've beaten or gotten a " ..
			    "100% clear on.",
	["HOW_TO_PLAY3"] = "Battle Mode",
	["HOW_TO_PLAY3a"] = "Battle Mode lets you set up special multiplayer contests with your friends " ..
			    "and guildmates. You can pick the level, adjust how many shots each person is " ..
			    "allowed, and how long the battle will be active for. Then send out invitations " ..
			    "to your friends!\n\n" ..

			    "When you click the Battle Mode tab you can either select an existing " ..
			    "Battle that you've entered, or create a new one. If you select one that " ..
			    "you've already played, you can see the current leaderboard.\n\n" ..

			    "The leaderboard also shows icons to indicate which character the player used " ..
			    "as well as the number of levels they've beaten and how many 100% clears they've " ..
			    "achieved.",
	["HOW_TO_PLAY3b"] = "Battles that have run out of time will eventually decay off your list.",
	["HOW_TO_PLAY4"] = "Peggle Loot",
	["HOW_TO_PLAY4a"] = "Peggle Loot is a fun way to distribute loot in a Master Looter party or raid. " ..
			   "When activated, all players in the party or raid with the add-on will get the " ..
			   "option to play a single shot high score challenge for the item. Whoever scores " ..
			   "the highest wins the right to the item!\n\n"..

			   "If you are the Loot Master in a party or raid, simply type |cFFFFFF00/peggleloot|r to " ..
			   "initiate the challenge. Optionally, you can also shift-click the item to add " ..
			   "an item link after the peggleloot command.",
	["HOW_TO_PLAY4b"] = "The addon will pick a random level, and then send that challenge to all members " ..
			    "of the party or raid. They will have the option to play or pass. If they play, " .. 
			    "they get a single shot to score as many points as possible.\n\n" ..
 
			    "To make it fair, talents are disabled for the shot and all users are defaulted " ..
			    "to Splork. Players have 30 seconds to complete their shots from when the Peggle " ..
			    "Loot challenge is activated.\n\n" ..
 
			    "Once all players have competed, their scores are shown and the winner declared! " ..
			    "The Loot Master should then assign the loot to the winner of the challenge.",
	["INVITEES"] = "INVITEES",
	["INVITED"] = "|cFFFF8C00(%d INVITED)",
	["INVITE_PERSON"] = "INVITE INDIVIDUAL:",
	["INVITE_NOTE"] = "NOTE TO INVITEES",
--	["LEARN"] = "Click to learn",		-- part of Blizzard UI

	["LEGAL1"] = "(c) 2000, 2009 PopCap Games Inc. All right reserved",
	["LEGAL2"] = --"Peggle\n\n\n" ..
		     "(c)2007, 2009 PopCap Games, Inc.  All rights reserved.  This application is " .. 
		     "being made available free of charge for your personal, non-commercial entertainment " ..
		     "use, and is provided \"as is\", without any warranties.  PopCap Games, Inc. will have " ..
		     "no liability to you or anyone else if you choose to use it.  See readme.txt for details.",
	["_LEVEL_INFO"] = "Level %d: %s",
	["_LEVEL_NAME1"] = "Ironforge",
	["_LEVEL_NAME2"] = "Orgrimmar",
	["_LEVEL_NAME3"] = "Stormwind",
	["_LEVEL_NAME4"] = "Undercity",
	["_LEVEL_NAME5"] = "Darnassus",
	["_LEVEL_NAME6"] = "Thunder Bluff",
	["_LEVEL_NAME7"] = "Dark Portal",
	["_LEVEL_NAME8"] = "Exodar",
	["_LEVEL_NAME9"] = "Silvermoon City",
	["_LEVEL_NAME10"] = "Shattrath City",
	["_LEVEL_NAME11"] = "Dalaran",
	["_LEVEL_NAME12"] = "Icecrown Citadel",

	["MENU"] = "MENU",
	["MOST_RECENT"] = "MOST RECENT:",
	["MOUSE_OVER"] = "Mouse over a talent for more information",
	["NEW"] = " |cffffff00(NEW!)",
	["_NEXT"] = "NEXT ",
	["NO_SCORE"] = "PLAY LEVEL TO EARN A SCORE!",
	["NOT_PLAYED"] = "Not yet played",
	["OPPONENT"] = "OPPONENT:",
	["OPPONENT_NOTE"] = "NOTE TO OPPONENT",
	["OPPONENT_NOTE2"] = "NOTE FROM OPPONENT",

--	["OPT_KEYBIND"] = "Show/Hide Keybinding",
	["OPT_TRANS_DEFAULT"] = "Mouse-on Transparency",
	["OPT_TRANS_MOUSE"] = "Mouse-off Transparency",
	["OPT_MINIMAP"] = "Show Mini-map Icon",
	["OPT_NEW_ON_FLIGHT"] = "New Game on Flight Start",
	["OPT_SOUNDS"] = "Sounds:",
	["OPT_SOUNDS_NORMAL"] = "Normal",
	["OPT_SOUNDS_QUIET"] = "Quiet",
	["OPT_SOUNDS_OFF"] = "Off",
	["OPT_LOCK"] = "Lock Window",
	["OPT_COLORBLIND"] = "Color Blind Mode",
	["OPT_HIDEOUTDATED"] = "Hide Outdated Chat Notifications",
	["OPT_AUTO_OPEN"] = "Auto-Open:",
	["OPT_AUTO_OPEN1"] = "On Flight Start",
	["OPT_AUTO_OPEN2"] = "On Death",
	["OPT_AUTO_OPEN3"] = "On Log-in",
	["OPT_AUTO_OPEN4"] = "Duel Invite",
	["OPT_AUTO_CLOSE"] = "Auto-Close:",
	["OPT_AUTO_CLOSE1"] = "On Flight End",
	["OPT_AUTO_CLOSE2"] = "On Ready Check",
	["OPT_AUTO_CLOSE3"] = "On Enter Combat",
	["OPT_AUTO_CLOSE4"] = "Duel Complete",
	["OPT_AUTO_CLOSE5"] = "Peggle Loot Complete",
	["OPT_DUEL_INVITES"] = "Duel/Battle Invites:",
	["OPT_DUEL_INVITES1"] = "Chatbox Text Alert",
	["OPT_DUEL_INVITES2"] = "Raid Warning Text Alert",
	["OPT_DUEL_INVITES3"] = "Mini-map Icon Alert",
	["OPT_DUEL_INVITES4"] = "Auto-decline Duels",

	["OPTIONAL"] = "|cFFFF8C00(OPTIONAL)",
	["ORANGE_PEGS"] = "Orange\nPegs",
	["OUT_OF_DATE"] = "|cFFFFFFFFThis version of Peggle is out-of-date! Visit |r|cFFFFFF00www.popcap.com/wow|r|cFFFFFFFF for the latest version!",
	["_OUTDATED"] = "%s has invited you to a %s using an old version of this addon. Unfortunately, the versions are no longer compatible. Please ask them to upgrade to the latest version.",
	["_PEGS_HIT"] = "%s x %d |4PEG:PEGS",
	["_PEGGLE_ISSUE1"] = "[Peggle] We're very sorry but it appears the battle data being saved is invalid and was not saved. Please report this error to wowaddons@popcap.com with as much detail as possible so we can fix it in future versions.",
	["PEGGLE_ISSUE2"] = "Part of the Peggle addon is corrupt. Please re-download the Peggle addon to fix this issue.",

	["PEGGLELOOT_DESC"] = "Highest Scoring Single Shot Wins", --Get the best score with only one shot, with Peggle talents disabled, to receive %s!",
	["_PEGGLELOOT_ISACTIVE"] = "Peggle Loot is already active! %d seconds remain in current challenge.",
	["_PEGGLELOOT_NOTIFY"] = "Peggle One-Shot Loot System Initialized for %s! Results released in 40 seconds. If you do not have the Peggle Addon, you're missing out!",
	["_PEGGLELOOT_CHAT_REMAINING"] = "Peggle Loot results in %d seconds!",
	["_PEGGLELOOT_NOTMASTERLOOTER"] = "PeggleLoot requires you to be the Master Looter.",
	["_PEGGLELOOT_NOWINNER"] = "*** No winner found! ***", 
	["PEGGLELOOT_REMAINING"] = "Time remaining: %d sec",
	["_PEGGLELOOT_RESULTS"] = "Peggle Loot Results:", 
	["PEGGLELOOT_TITLE"] = "Peggle Loot Challenge",
	["_PEGGLELOOT_WINNER"] = "*** Winner: %s ***", 
	["_PEGGLELOOT_WRONGMETHOD"] = "Peggle Loot requires the loot mode to be Master Looter.",

	["PERSONAL_BEST"] = "PERSONAL BEST:",
	["PERSONAL_BEST_PTS"] = "%s PTS",

	["_PUBLISH_SCORE"] = "[Peggle]: %s just scored %s points on %s! Download the Peggle Addon for Wow to defeat their score!",
	["_PUBLISH_DUEL_W"] = "[Peggle]: %s just defeated %s in a Peggle Duel! Download the Peggle Addon for Wow to pit your skills against them!",
	["_PUBLISH_DUEL_L"] = "[Peggle]: %s was just defeated by %s in a Peggle Duel! Download the Peggle Addon for Wow to pit your skills against them!",
	["_PUBLISH_1"] = CHAT_MSG_GUILD,
	["_PUBLISH_2"] = CHAT_MSG_PARTY,
	["_PUBLISH_3"] = CHAT_MSG_RAID,

	["QUICK_PLAY"] = "QUICK PLAY",
	["PLAYING"] = "Playing",
	["_POINT_BOOST"] = "POINT BOOST!",
	["_POINTS_LEFT"] = "Points left to spend",
	["_RANK"] = "Rank (%d/%d)",
	["_REQUIRES_5"] = "|cFFFF0000Requires 5 points in %s.\n",
	["_REQUIRES_X"] = "|cFFFF0000Requires %d points in Peggle Talents.\n",
	["SELECT_LEVEL"] = "SELECT A LEVEL",
	["SCORE"] = "Score",
	["SCORE_BEST"] = "Best",
	["SCORE_TIME_LEFT"] = "Time Left: %s",
	["SCORES"] = "SCORES",
	["_SPECIAL_NAME1"] = "SUPER GUIDE",
	["_SPECIAL_NAME2"] = "SPACE BLAST",
	["_STYLE_COUNT"] = "+%s STYLE POINTS",

	["_STYLESHOT_1"] = "FREE BALL SKILLS!\n+",
	["_STYLESHOT_2"] = "LONG SHOT!\n+",
	["_STYLESHOT_3"] = "SUPER LONG SHOT!\n+",
	["_STYLESHOT_4"] = "MAD SKILLZ\n+",
	["_STYLESHOT_4a"] = "CRAZY MAD SKILLZ\n+",
	["_STYLESHOT_5"] = "EXTREME SLIDE!\n+",
	["_STYLESHOT_6"] = "ORANGE ATTACK!\n+",
	["_STYLESHOT_6a"] = "ORANGE ATTACK!\n+",

	["_SUMMARY_TITLE0"] = "NO MORE SHOTS",
	["_SUMMARY_TITLE1"] = "LEVEL COMPLETE",
	["_SUMMARY_TITLE2"] = "LEVEL FULLY CLEARED",
	["_SUMMARY_TITLE3"] = "LEVEL FINISHED",
	["_SUMMARY_TITLE4"] = "BATTLE FINISHED",
	["_SUMMARY_TITLE5"] = "LOOT SCORE SUBMITTED",

	["SUMMARY_SCORE_BEST"] = "Best Score On This Level: |cFFFFFFFF%s",
	["SUMMARY_SCORE_YOURS"] = "Score: |cFFFFFFFF%s",
	["SUMMARY_STAT1"] = "Shots:",
	["SUMMARY_STAT2"] = "Free Balls:",
	["SUMMARY_STAT3"] = "% Cleared:",
	["SUMMARY_STAT4"] = "Talent Score:",
	["SUMMARY_STAT5"] = "Fever Score:",
	["SUMMARY_STAT6"] = "Style Points:",

	["_TALENT1_NAME"] = "TWO-SIDED COIN",
	["_TALENT1_DESC"] = "Increases your chance of getting a free-ball when you don't hit any pegs by %d%%.",
	["_TALENT2_NAME"] = "STYLE FOR MILES",
	["_TALENT2_DESC"] = "Increases the points you receive for style shots by %d%%.",
	["_TALENT3_NAME"] = "A STEP AHEAD",
	["_TALENT3_DESC"] = "Your fever bonus meter starts with %d |4notch:notches; lit at the beginning of the match.",
	["_TALENT4_NAME"] = "THE ONLY CURE",
	["_TALENT4_DESC"] = "The points awarded by end of level Fever Buckets is increased by %d%%.",
	["_TALENT5_NAME"] = "PEG MARKSMAN",
	["_TALENT5_DESC"] = "When you hit a peg, you have a %d%% chance to \"crit\" receiving 150%% of that peg's points.",
	["_TALENT6_NAME"] = "MORE COWBELL",
	["_TALENT6_DESC"] = "Purple pegs have a %d%% chance to increase your fever meter by 1.",
	["_TALENT7_NAME"] = "MISSION CRITICAL",
	["_TALENT7_DESC"] = "Your Crit pegs are worth %d%% of the original peg's value.",
	["_TALENT8_NAME"] = "Unintended Awesome",
	["_TALENT8_DESC"] = "When you hit a green peg, the purple peg has a %d%% chance of erupting in a small explosion, scoring itself and other nearby pegs.",
	["_TALENT9_NAME"] = "Infusion of Awesome",
	["_TALENT9_DESC"] = "Pegs hit with your special power have a %d%% chance to crit. (First two pegs hit with a guided ball OR all pegs hit with a space blast).",
	["_TALENT10_NAME"] = "ROLLING IGNITION",
	["_TALENT10_DESC"] = "When you hit a green peg and land the ball in the bucket in the same shot, one of your blue pegs is converted to a green peg.",
	["_TALENT11_NAME"] = "DOUBLE FISSION",
	["_TALENT11_DESC"] = "When you hit a purple peg, you score bonus points for each peg already hit in the shot as if you hit it again. These bonus points may not crit.",

	["TALENTS"] = "TALENTS",
	["TALENTS_DESC"] = "Talents are 'passive' abilities that affect all characters",

	["_THE_ITEM"] = "the item",

	["_TOOLTIP_MINIMAP"] = "Left-click to show/hide game.\nRight-click to move icon.",
	["_TOTAL_MISS"] = "TOTAL MISS!",
	["_TURNS"] = " TURNS",

	["WIN_LOSS"] = "Win/Loss Record",
	["WIN_LOSS_LEVEL"] = "(On this level)",
	["WIN_LOSS_PLAYER"] = "W/L vs this opponent: %d - %d",
}

-- Talent rank calculation data
const.factors = {
	0, 10,		-- Start at 0, factors of 10
	0, 2,		-- Start at 0, factors of 2
	0, 1,		-- Start at 0, factors of 1
	0, 10,		-- Start at 0, factors of 10
	0, 5,		-- Start at 0, factors of 5
	0, 10,		-- Start at 0, factors of 10
	150, 10,	-- Start at 150, factors of 10
	0, 10,		-- Start at 0, factors of 10
	0, 20,		-- Start at 0, factors of 20
	0, 0,		-- Start at 0, factors of 0
	0, 0		-- Start at 0, factors of 0
}

local showGuide = nil;
local lastAngle = -1;
local fakeBall = {["x"] = 0; ["y"] = 0; ["xVel"] = 0; ["yVel"] = 0};
local numLines = 0;
local numPathPieces = 0;
local totalLines = 0;
local totalPathPieces = 0;
local Peggle = {};
local localPlayerName;
local scoreData = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

--local frame = {};
local animator;
local window;
local gameBoard;

local mod = math.fmod;
local abs = math.abs;
local sqrt = math.sqrt;
local sin = math.sin;
local cos = math.cos;
local floor = math.floor;
local random = math.random;
local rad = math.rad;
local min = math.min;
local max = math.max;
local deg = math.deg;

local byte = string.byte;
local char = string.char;
local sub = string.sub;
local tonumber = tonumber;
local tostring = tostring;

--local atan2 = math.atan2;

local tremove = table.remove;
local tinsert = table.insert;

local objects = {};

const.windowWidth = 662;
const.windowHeight = 548;
const.boardWidth = 554;
const.boardHeight = 464;
const.boardXYSections = 10;
const.sectionXSize = floor(const.boardWidth / const.boardXYSections + 0.9);
const.sectionYSize = floor(const.boardHeight / const.boardXYSections + 0.9);
const.ballWidth = 12;
const.ballHeight = 12;
const.ballRadius = 6;    -- 6
const.pegWidth = 28 * 0.85;
const.pegHeight = 28 * 0.85;
const.pegRadius = 10 * 0.85;   --85 / 10
const.brickWidth = 34 * 0.85;
const.brickHeight = 34 * 0.85;
const.brickRadius = 18 * 0.85;  -- 153 / 10
const.catcherWidth =  138;
const.catcherHeight = 27;
const.catcherLoopTime = 6;
const.zoomDistance = 48;

const.addonPath	= "Interface\\AddOns\\Peggle";
const.artPath	= "Interface\\AddOns\\Peggle\\images\\";
const.soundPath	= "Interface\\AddOns\\Peggle\\sounds\\";

const.boardBoundryBottom = 10 --const.ballRadius + 4;
const.boardBoundryLeft = 10 --const.ballRadius + 4;
const.boardBoundryTop = const.boardHeight - 2 --const.ballRadius - 4;
const.boardBoundryRight = const.boardWidth - 2 --const.ballRadius - 4;

const.cCount = 0;

const.artCut = {};
const.artCut["leftBorder"] =		{  0/512,  60/512,   0/512, 512/512 };
const.artCut["rightBorder1"]=		{  0/256, 152/256,   0/512, 140/512 };
const.artCut["rightBorder2"]=		{ 85/256, 152/256, 140/512, 488/512 };
const.artCut["rightBorder3"]=		{  0/256, 152/256, 488/512, 512/512 };
const.artCut["topBorder"] =		{ 60/512, 512/512,   0/512, 140/512 };
const.artCut["bottomBorder"] =		{ 60/512, 512/512, 488/512, 512/512 };
const.artCut["powerLabel"] =		{324/512, 506/512, 179/512, 203/512 };
const.artCut["catcher"] =		{100/512, 237/512, 413/512, 439/512 };
const.artCut["catcherBack"] =		{100/512, 237/512, 460/512, 486/512 };
const.artCut["extraBallBarTop"] =	{ 99/512, 110/512, 331/512, 347/512 };
const.artCut["extraBallBar"] =		{ 99/512, 110/512, 347/512, 363/512 };
const.artCut["extraBallBarBot"] =	{ 99/512, 110/512, 363/512, 379/512 };
const.artCut["extraBallBottomCover"] =	{ 99/512, 163/512, 383/512, 399/512 };
const.artCut["extraBallTopCover"] =	{167/512, 199/512, 373/512, 399/512 };
const.artCut["ballLoader"] =		{112/512, 135/512, 260/512, 379/512 };
--const.artCut["buttonMenu"] =		{145/512, 188/512, 309/512, 352/512 };
const.artCut["buttonInstantReplay"] =	{144/512, 189/512, 260/512, 305/512 };
const.artCut["glow"] =			{139/512, 202/512, 258/512, 322/512 };
const.artCut["catcherGlow"] =		{255/512, 377/512, 429/512, 481/512 };
const.artCut["feverBottomCover"] =	{ 64/512,  98/512, 384/512, 399/512 };
const.artCut["feverTopCover"] =		{ 64/512,  98/512, 366/512, 381/512 };
const.artCut["feverBar"] =		{ 64/512,  95/512, 352/512, 364/512 };
const.artCut["feverBarHighlight"] =	{ 64/512,  95/512, 339/512, 351/512 };
const.artCut["fever2x"] =		{202/512, 248/512, 349/512, 370/512 };
const.artCut["fever2xHighlight"] =	{252/512, 298/512, 349/512, 370/512 };
const.artCut["fever3x"] =		{202/512, 248/512, 324/512, 345/512 };
const.artCut["fever3xHighlight"] =	{252/512, 298/512, 324/512, 345/512 };
const.artCut["fever5x"] =		{202/512, 248/512, 299/512, 320/512 };
const.artCut["fever5xHighlight"] =	{252/512, 298/512, 299/512, 320/512 };
const.artCut["fever10x"] =		{202/512, 248/512, 274/512, 295/512 };
const.artCut["fever10xHighlight"] =	{252/512, 298/512, 274/512, 295/512 };
const.artCut["feverBonus10"] =		{200/512, 313/512, 208/512, 258/512 };
const.artCut["feverBonus50"] =		{313/512, 423/512, 208/512, 258/512 };
const.artCut["feverBonus100"] =		{201/512, 313/512, 148/512, 205/512 };
const.artCut["fever1"] =		{  0/512, 512/512,  92/256, 256/256 };
const.artCut["fever2"] =		{  0/512, 512/512,  13/256,  92/256 };
const.artCut["feverScore"] =		{171/256, 256/256,   0/512, 268/512 };
const.artCut["feverRay"] =		{394/512, 452/512, 287/512, 481/512 };
const.artCut["logoArt"] =		{305/512, 390/512, 261/512, 426/512 };
const.artCut["tabQuickPlay"] =		{  0/512, 118/512,   0/256,  64/256 };
const.artCut["tabDuel"] =		{118/512, 203/512,   0/256,  64/256 };
const.artCut["tabChallenge"] =		{203/512, 319/512,   0/256,  64/256 };
const.artCut["tabTalents"] =		{319/512, 416/512,   0/256,  64/256 };
const.artCut["tabHowToPlay"] =		{  0/512, 141/512, 192/256, 256/256 };
const.artCut["tabOptions"] =		{416/512, 512/512,   0/256,  64/256 };
const.artCut["buttonOkay"] =		{  0/256, 158/256,   0/256,  54/256 };
const.artCut["buttonGo"] =		{  0/256, 158/256,  54/256, 108/256 };
const.artCut["buttonResetTalents"] =	{175/256, 219/256,  25/256, 182/256 };
const.artCut["buttonNewChallenge"] =	{  0/256, 125/256, 109/256, 141/256 };
const.artCut["buttonChallenge"] =	{  0/256, 175/256, 142/256, 183/256 };
const.artCut["buttonRestartLevel"] =	{  0/256, 185/256, 184/256, 220/256 };
const.artCut["buttonReturnToGame"] =	{  0/256, 185/256, 220/256, 256/256 };
const.artCut["buttonAbandonGame"] =	{220/256, 256/256,  70/256, 256/256 };
const.artCut["buttonSound"] =		{162/256, 182/256,   0/256,  20/256 };
const.artCut["buttonMenu"] =		{202/256, 256/256,   0/256,  20/256 };
const.artCut["buttonClose"] =		{235/256, 255/256,  19/256,  39/256 };
const.artCut["buttonView"] =		{191/256, 215/256, 186/256, 256/256 };
const.artCut["buttonBack"] =		{186/256, 256/256, 319/512, 343/512 };
const.artCut["buttonAbout"] =		{  0/256,  44/256, 141/512, 298/512 };
const.artCut["buttonCredits"] =		{  0/256,  44/256, 298/512, 457/512 };
const.artCut["buttonPublish"] =		{155/256, 199/256, 354/512, 480/512 };
const.artCut["buttonDecline"] =		{202/256, 256/256, 355/512, 512/512 };
const.artCut["bannerBig1"] =		{128/256, 256/256,   0/256, 183/256 };
const.artCut["bannerBig2"] =		{  0/256, 128/256,   0/256, 183/256 };
const.artCut["bannerSmall1"] =		{  0/512,  36/512, 467/512, 512/512 };
const.artCut["bannerSmall2"] =		{  0/512,  36/512, 422/512, 467/512 };
const.artCut["bannerSmall3"] =		{  0/512,  36/512, 377/512, 422/512 };
const.artCut["howToPlay1"] =		{  0/512, 195/512,   0/512, 155/512 };
const.artCut["howToPlay2"] =		{197/512, 392/512,   0/512, 155/512 };
const.artCut["howToPlay3"] =		{  0/512, 195/512, 155/512, 310/512 };
const.artCut["howToPlay4"] =		{197/512, 392/512, 155/512, 310/512 };
const.artCut["howToPlay5"] =		{  0/512, 195/512, 311/512, 404/512 }; --437/512 };
const.artCut["howToPlay6"] =		{194/512, 391/512, 311/512, 367/512 }; --404/512 };
const.artCut["howToPlay7"] =		{194/512, 391/512, 405/512, 443/512 };
const.artCut["howToPlay8"] =		{  0/512, 382/512, 444/512, 481/512 };
const.artCut["popCap"] =		{117/512, 187/512, 181/512, 251/512 };
const.artCut["peggleBringer"] =		{453/512, 512/512, 207/512, 487/512 };
const.artCut["splashBringer"] =		{ 60/512, 512/512, 368/512, 512/512 };
const.artCut["exhibitA"] =		{439/512, 512/512,   0/512, 373/512 };
const.artCut["exhibitA2"] =		{448/512, 512/512, 389/512, 453/512 };

const.brickTex = {"blue", "red", "purple", "green"};
const.talentTex = {
	"t_coin",
	"t_style_for_miles",
	"t_a_step_ahead",
	"t_the_only_cure",
	"t_peg_marksmen",
	"t_more_cowbell",
	"t_mission_critical",
	"t_unintended_awesome",
	"t_infusion_of_awesome",
	"t_rolling_ignition",
	"t_double_fission",
};

-- Polygons are created from the top-right vertex x, y ... and then each vertex is in
-- clockwise order. Every pair represents an edge. The vertices are in relation to the
-- the center of the polygon, for the purpose of apply rotation and coordinates
--
-- For polygon #2, it breaks down like so:
--  7,-15 to 10,-1
-- 10,0 to 7,14
-- 7,14 to -10,7
-- -10,7 to -9,0
-- -9,-1 to -10,-8
-- -10,-8 to 7,-15

--[[
const.polygon = {
	{7,	-11,	9,	-4,	9,	3,	7,	10,	-10,	3,	-10,	-4},	-- [1] 10
	{7,	-15,	10,	-1,	7,	14,	-10,	7,	-9,	0,	-10,	-8},	-- [2] 20
	{7,	-13,	9,	-6,	9,	5,	7,	12,	-10,	7,	-10,	-8},	-- [3] 30
	{8,	-12,	9,	-4,	9,	3,	8,	12,	-9,	9,	-8,	0,	 -9,	-9},	-- [4] 40
	{9,	-14,	10,	-6,	10,	5,	9,	14,	-10,	11,	-10,	-11},	-- [5] 60
	{8,	-13,	9,	-8,	9,	6,	8,	12,	-10,	10,	-10,	-11},	-- [6] 80
	{8,	-15,	9,	-7,	9,	6,	8,	15,	-10,	13,	-10,	-13},	-- [7] 100
	{8,	-15,	9,	-9,	9,	7,	8,	14,	-9,	12,	-9,	6,	-9,	-8,	-9,	-13},	-- [8] 120
	{8,	-15,	9,	-6,	9,	5,	8,	13,	-10,	11,	-10,	6,	-10,	-7,	-10,	-13},	-- [9] 140
	{8,	-15,	9,	-8,	9,	7,	8,	14,	-10,	13,	-10,	-14},	-- [10] 160
	{8,	-15,	9,	-8,	9,	7,	8,	15,	-10,	14,	-10,	-14},	-- [11] 180
	{-10,	-15,	9,	-15,	9,	14,	-10,	14},	-- [12]
}
--]]
const.polygon = {
	{7,	-11,	9,	-4,	9,	3,	7,	10,	-10,	3,	-10,	-4},	-- [1] 10
	{7,	-15,	10,	-1,	7,	14,	-10,	7,	-9,	0,	-10,	-8},	-- [2] 20
	{7,	-13,	9,	-6,	9,	5,	7,	12,	-10,	7,	-10,	-8},	-- [3] 30
	{8,	-12,	9,	-4,	9,	3,	8,	12,	-9,	9,	-8,	0,	 -9,	-9},	-- [4] 40
	{9,	-14,	10,	-6,	10,	5,	9,	14,	-10,	11,	-10,	-11},	-- [5] 60
	{8,	-13,	9,	-8,	9,	6,	8,	12,	-10,	10,	-10,	-11},	-- [6] 80
	{8,	-15,	9,	-7,	9,	6,	8,	15,	-10,	13,	-10,	-13},	-- [7] 100
	{8,	-15,	9,	-9,	9,	7,	8,	14,	-9,	12,	-9,	6,	-9,	-8,	-9,	-13},	-- [8] 120
	{8,	-15,	9,	-6,	9,	5,	8,	13,	-10,	11,	-10,	6,	-10,	-7,	-10,	-13},	-- [9] 140
	{8,	-15,	9,	-8,	9,	7,	8,	14,	-10,	13,	-10,	-14},	-- [10] 160
	{8,	-15,	9,	-8,	9,	7,	8,	15,	-10,	14,	-10,	-14},	-- [11] 180
	{9,	-15,	9,	14,	-9,	14,   -9,     -15},	-- [12]
}

const.temp1 = {1, 4, 5, 6};
const.temp2 = {1, 3, 4, 6};
const.temp3 = {1, 4, 5, 7};
const.temp4 = {1, 4, 5, 8};
const.temp5 = {1, 2, 3, 4};
const.polygonCorners = {
	const.temp1,
	const.temp2,
	const.temp1,
	const.temp3,
	const.temp1,
	const.temp1,
	const.temp1,
	const.temp4,
	const.temp4,
	const.temp1,
	const.temp1,
	const.temp5,
}
const.temp1 = nil;
const.temp2 = nil;
const.temp3 = nil;
const.temp4 = nil;
const.temp5 = nil;

--]]
--const.polygon[2] = {7, -15, 10, -1, 7, 14, -10, 7, -9, 0, -10, -8};
--const.polygon[8] = {8, -15, 9, -5, 9, 3, 8, 13, -10, 11, -10, -13};

const.catcherPolygon = {49, -7, 51, -9, 73, 8, 51, 32, -51, 32, -74, 8, -51, -9, -49, -7, -49, 31, 49, 31};

-- Orange attack ranges
const.ranks = {
	5, 4,	-- 5 pegs left, need to hit 4
	6, 5,	-- At least 6 pegs left, need to hit 5
	8, 6,	-- 8 pegs left, need to hit 6
	9, 7,	-- 9 pegs left, need to hit 7
	10, 8,  -- At least 10 pegs left, need to hit 8
	16, 9,	-- At least 16 pegs left, need to hit 9
	20, 10, -- At least 20 pegs left, need to hit 10
}

const.polyTable = {};
const.dropInfo = {};

const.curvedBrick = {
	[0] = 12;
	[10] = 1;
	[20] = 2;
	[30] = 3;
	[40] = 4;
	[60] = 5;
	[80] = 6;
	[100] = 7;
	[120] = 8;
	[140] = 9;
	[160] = 10;
	[180] = 11;
}

const.starColors = {
	1,0.3,0.3,
	0.3,1,0.3,
	0.3,0.3,1,
	1,1,0.3,
	1,0.3,1,
	0.3,1,1,
	1,1,1,
};

const.stats = {0, 0, 0, 0, 0, 0, 0};

const.oldUsers = {};

--[[ Notes
talentData[((i-1) * 3) + 1] = tier
talentData[((i-1) * 3) + 2] = maxRank
talentData[((i-1) * 3) + 3] = prereq
talentData[last 11] = current rank for each of 11 talents
--]]

local talentData = {
	0, 5, 0,
	0, 5, 0,
	1, 2, 0,
	1, 5, 0,
	1, 3, 0,
	2, 5, 0,
	2, 5, 0,
	3, 5, 0,
	3, 5, 0,
	4, 1, 8,
	4, 1, 9,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

const.commands = {
	"di",	-- [1] : Duel Invite
	"dr",	-- [2] : Duel Receieved
	"dd",	-- [3] : Duel Declined
	"da",	-- [4] : Duel Accepted
	"db",	-- [5] : Duel Opponent is Busy
	"df",	-- [6] : Duel Finished (if no score, opponent gave up)
	"dc",	-- [7] : Duel Cancelled

	"ping", -- [8] : Pinging to see if someone is online
	"pong", -- [9] : Ponging to let the person know that the addon is on

	"ccs",	-- [10]	: Challenge - Check for server
	"csu",  -- [11]	: Challenge - Server is unknown (not yet established)
	"csn",	-- [12] : Challenge - Server Name is ... ______
	"cqr",	-- [13] : Challenge - Query Request (get scores from player)
	"cqa",	-- [14] : Challenge - Query Answer (give scores to server)
	"cgc",  -- [15] : Challenge - Give challenge to player
	"cnc",  -- [16] : Challenge - Need challenge? 
	"cdn",  -- [17] : Challenge - Don't need challenge (has it)
	"cdh",  -- [18] : Challenge - Don't have challenge (needs it like water)
	"cgs",	-- [19] : Challenge - Giving score to server (we finished the level)

	"plg",	-- [20] : Peggle Loot - Give challenge to player
	"pls",	-- [21] : Peggle Loot - Score from shot returned to server
	"plp",	-- [22] : Peggle Loot - Passed (did not accept)
};

const.sounds = {
	"applause.ogg", --applause.ogg",			--1
	"", --AwardFanfareV2.ogg",
	"ball_add.ogg",
	"", --buckethit.ogg",
	"cannonshot.ogg",		--5
	"coin_spin.ogg",
	"coin_freeball_denied.ogg",
	"extraball.ogg",
	"extraball2.ogg",
	"extraball3.ogg",		--10
	"extremefever2.ogg",
	"feverhit.ogg",
	"", --FireworkPop.ogg",
	"fireworks2.ogg",
	"gapbonus1.ogg",		--15
	"gong.ogg",
	"odetojoy.ogg",
	"peghit",
	"pegpop.ogg",
	"", --pegspark.ogg",			--20
	"aah.ogg",
	"powerup_guide.ogg",
	"powerup_spaceblast.ogg",
	"rainbow.ogg",
	"scorecounter.ogg",		--25
	"sigh.ogg",
	"timpaniroll.ogg",
	"xbump_mod2.ogg",
	"aah.ogg",			--29
};

const.SOUND_APPLAUSE = 1;
const.SOUND_AWARD = 2;
const.SOUND_BALL_ADD = 3;
const.SOUND_BUCKET_HIT = 4;
const.SOUND_BUCKET_BALL = 29;
const.SOUND_BUMPER = 28;
const.SOUND_COIN_SPIN = 6;
const.SOUND_COIN_DENIED = 7;
const.SOUND_EXTRABALL1 = 8;
const.SOUND_EXTRABALL2 = 9;
const.SOUND_EXTRABALL3 = 10;
const.SOUND_FEVER = 11;
const.SOUND_FEVER_HIT = 12;
const.SOUND_FIREWORK_POP = 13;
const.SOUND_FIREWORKS_START = 14;
const.SOUND_GAP_BONUS = 15;
const.SOUND_GONG = 16;
const.SOUND_ODETOJOY = 17;
const.SOUND_PEG_HIT = 18;
const.SOUND_PEG_POP = 19;
const.SOUND_PEG_SPARK = 20;
const.SOUND_POWERUP = 21;
const.SOUND_POWERUP_GUIDE = 22;
const.SOUND_POWERUP_BLAST = 23;
const.SOUND_RAINBOW = 24;
const.SOUND_SCORECOUNTER = 25;
const.SOUND_SHOT = 5;
const.SOUND_SIGH = 26;
const.SOUND_TIMPANI = 27;

const.channels = {"GUILD", "PARTY", "RAID"};

const.sentList = {};
const.onlineList = {};
const.offlineList = {};
const.currentView = {0,0,0,0,0,0,{},{}};
const.newInfo = {"id", "names", "namesWithoutChallenge", "creator", "note", "new", "elapsed", "ended", "removed", "played", "peggleLoot", "peggleLootNames", "peggleLootActive", "dirty"};
const.days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
-- Chat filter so the player doesn't get spammeded with "player is not online" messages
const.filterText = string.gsub(ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(.+)") ;

local SHOOT_FORCE	= 260;	-- Force that the ball get's launched with, pixels per second
local GRAVITY		= -248;	-- Force that acts upon the ball's vertical velocity, pixels per second
--local RESISTANCE	= 0;	-- Force that acts upon the ball's horizontal velocity, pixels per second
local ELASTICITY	= 0.68;	-- Elastic force displacement when the ball hits an object. Should be between 0 and 1
local ANGLE		= 270;	-- Angle to fire the ball at ... not really supposed to be constant.
local SHOOTER_ANGLE	= 270;  -- Angle that the shooter uses for rotation purposes.
local GUIDE_HITS	= 1;

local PEG_PURPLE_VALUE	= (333 + 167);
local PEG_RED_VALUE	= (9 + 1) * (8 + 2);
local PEG_BLUE_VALUE	= 6 + 4;
local PEG_GREEN_VALUE	= 3 + 7;

local PEG_BLUE		= 1;
local PEG_RED		= 2;
local PEG_PURPLE	= 3;
local PEG_GREEN		= 4;

const.ANI_NONE		= 0;
const.ANI_LINE		= 1;
const.ANI_CIRCLE	= 2;
const.ANI_ROTATOR	= 3;
const.ANI_LINE_ROTATOR	= 4;
const.ANI_CIRCLE_ROT	= 5;

local OBJ_PEG		= 0;
local OBJ_CURVED_BRICK	= 1;
local OBJ_BRICK		= 2;

local SPECIAL_GUIDE	= 0;
local SPECIAL_BLAST	= 1;

-- Fever = 0.5
-- "Gonna hit last peg?" = 0.2
-- Normal = 1;
local GAME_SPEED = 1; 

local feverMultiplier = 1;	-- Multiplier from fever
local feverPegsHit = 0;		-- Total fever pegs hit this level (25 per level)
local feverPegsTotal = 0;	-- Total fever pegs at start of level (25 per level);
local feverBarsLit = 0;		-- Total number of fever bars active (25 total)
local orangeAttackCount = 0;	-- Total number of orange pegs to hit to get the style shot
local slideComboCount = 0;	-- Total number of "slides" that have happened in a 
local totalScore = 0;
--local totalScoreTalents = 0;
local currentScore = 0;		-- Current calculated total round score
local roundScore = 0;		-- Calculated round score (hits only)
local roundScoreTalents = 0;	-- Calculated round score (hits only, with talents)
local bonusScore = 0;		-- Calculated bonus score (from special acts)
local bonusScoreTalents = 0;	-- Calculated bonus score (from special acts, with talents)
local pegsHit = 0;		-- Total pegs hit so far
local ballCount = 0;

local specialName = "data";	-- red herring.
local specialCount = 0;
local specialType = SPECIAL_GUIDE;
local specialInPlay = nil;

local lastPeg = nil;
local freeBallCombo = 0;
local freeBallComboGet = 0;

local lastZoomDistance;
local DATA	-- Set during the Initialize function =)

-- Fake values, real ones are loaded later.

local theBallRadius = 10;
local thePegRadius = 4;
local theBrickRadius = 9;

local hitPolyInfo = {};

local currentLevelString = "";

local bgIndex = 1;

local gameOver = true;
local shooterReady = false;

local currentScoreText;

local gameObjectDB = {};
local availablePegs = {};

local playerChallenges;
local playerData;

PeggleData = {};
PeggleData.data = "i4g`Z@a`````````````````````````````````````````````````P7Vmr=h7ZuSBG"; -- 12 levels, 12 achievements, 12 best scores, 11 talents
PeggleData.settings = {
	mouseOnTrans = 1,
	mouseOffTrans = 0.6,
	showMinimapIcon = true,
	openFlightStart = true,
	openDeath = true,
	openLogIn = true,
	openDuel = true,
	closeFlightEnd = false,
	closeReadyCheck = true,
	closeCombat = true,
	closeDuelComplete = false,
	closePeggleLoot = false,
	inviteChat = true,
	inviteRaid = false,
	inviteMinimap = true,
	inviteDecline = false,
	hideOutdated = false;
	soundVolume = 0,
	minimapAngle = 270,
	defaultPublish = "GUILD",
};
PeggleData.version = const.versionID;
PeggleData.recent = {};

PeggleProfile = {};
PeggleProfile.challenges = {};
PeggleProfile.version = const.versionID;
PeggleProfile.lastDuels = {};
PeggleProfile.levelTracking = {};
PeggleProfile.duelTracking = {};

function Peggle.MinuteDifference(hour, minute, day, month, year)
--/script --printd(Peggle.MinuteDifference(3, 9, 28, 3, 2009));
--/script --printd(Peggle.MinuteDifference(3, 9, 31, 12, 2008));

	local _, thisMonth, thisDay, thisYear = CalendarGetDate();
	local thisHour, thisMinute = GetGameTime();

	local minutesSoFar = 0;

	-- Handle events that are two+ years apart
	if (thisYear - year > 1) then
		minutesSoFar = 525600;

	-- Handle events that are 12+ months apart. We will NEVER have this many months
	-- apart for a challenge, but this is in the case that people haven't logged
	-- in for a while...
	elseif (thisYear - year >= 1) and (12 - month + thisMonth >= 12) then
		minutesSoFar = 525600;

	-- Handle all other situations
	else
		local monthI, daysInCurrentMonth
		local totalDays = 0;
		-- Handle situations where the start day is one month before the end
		-- month (for challenges starting on, say, the 30th, and ending on
		-- the 1st)
		if (month < thisMonth) then
			for monthI = month, thisMonth - 1 do 
				daysInCurrentMonth = const.days[monthI];
				-- Address leap year.
				if (monthI == 2) and (mod(year, 4) == 0) then
					daysInCurrentMonth = daysInCurrentMonth + 1;
				end
				totalDays = totalDays + daysInCurrentMonth;
			end
		
		-- Handle situations where the start day falls in a month that is
		-- after the end day of a month (i.e., starting on Dec 31st and
		-- ending January 1st.)
		elseif (month > thisMonth) then
			for monthI = month, 12 do 
				daysInCurrentMonth = const.days[monthI];
				-- Address leap year.
				if (monthI == 2) and (mod(year, 4) == 0) then
					daysInCurrentMonth = daysInCurrentMonth + 1;
				end
				totalDays = totalDays + daysInCurrentMonth;
			end
			for monthI = 1, thisMonth - 1 do 
				daysInCurrentMonth = const.days[monthI];
				-- Address leap year.
				if (monthI == 2) and (mod(thisYear, 4) == 0) then
					daysInCurrentMonth = daysInCurrentMonth + 1;
				end
				totalDays = totalDays + daysInCurrentMonth;
			end

		end
		totalDays = totalDays - day + thisDay;

		-- Convert the days into hours
		minutesSoFar = totalDays * 24;

		-- Subtract the hours in the start day that do not count (i.e., if
		-- the challenge started at 10 am, we don't count the first 10
		-- hours) and then add the hours into the current day.
		minutesSoFar = minutesSoFar - hour + thisHour;

		-- Convert to minutes
		minutesSoFar = minutesSoFar * 60;

		-- Subtract the minutes in the start day that do not count (i.e., if
		-- the challenge started at 10:20 am, we don't count the first 20
		-- minutes of the hour) and then add the minutes into the current hour.
		minutesSoFar = minutesSoFar - minute + thisMinute;

-- other : 2/3/2008 19:29
-- today : 2/5/2008 19:29  -- minutes = 2 days * 24 hours + 0 hours + 0 minutes = 48 hours * 60 minutes
-- today : 3/1/2008 19:29  -- minutes = (28 days - 3 days into month) + 1 day into month = (26 days * 24 hours * 60 minutes) + 0 hours + 0 minutes = 

-- other : 12/31/08 23:00
-- today : 1/1/09 01:00	   -- minutes = 31 days - 31 days into month) + 1 day into month = 1 day * 24 hours - 23 hours + 1 hour = 2 hours

-- other : 12/31/08 10:20  -- minutes = 31 day - 31 thisDay = 0 * 24 - 10 hours + 14 hours = 4 hours * 60 = 240 minutes - 20 + 10 = 230 minutes;
-- total : 12/31/08 14:10

-- other : 12/31/08 10:20  -- minutes = 31 day - 31 thisDay = 0 * 24 - 10 hours + 10 hours = 0 hours * 60 = 0 minutes - 30 + 20 = 10 minutes;
-- total : 12/31/08 10:30

	end

	return minutesSoFar
	
end

function Peggle.TimeBreakdown(minutes)
	local hours;
	hours = floor(minutes/60);
	minutes = minutes - (hours * 60);
	return hours, minutes;
end

function Peggle.TableFind(tbl, findValue)

	local index, i;

	for i = 1, #tbl do 
		if (tbl[i] == findValue) then
			index = i;
			break;
		end
	end

	return index

end

function Peggle.TableRemove(tbl, removeValue)

	local index, j;
	local tblLength = #tbl;
	local i = 1;

	for j = 1, tblLength do 
		if (tbl[i] == removeValue) then
			tremove(tbl, i);
		else
			i = i + 1;
		end
	end
	
end

function Peggle.TableInsertOnce(tbl, insertValue, sortIt)

	local i, found
	local tblLength = #tbl;
	for i = 1, tblLength do 
		if (tbl[i] == insertValue) then
			found = true;
		end
	end

	if not found then
		tinsert(tbl, insertValue);
		if sortIt then
			table.sort(tbl)
		end
	end

	return not found;
	
end

function Peggle.TablePack(tbl, ...)
	local i;
	for i = 1, select('#', ...) do 
		tinsert(tbl, (select(i, ...)));
	end
end

local function NumberWithCommas(number)
	local numberComma = string.gsub(number, "(%d)(%d%d%d)$", "%1,%2")
	local found
	while true do
		numberComma, found = string.gsub(numberComma, "(%d)(%d%d%d),", "%1,%2,")
		if found == 0 then
			break
		end
	end
	return numberComma
end

local function Sound(soundID)

	if (window.soundButton.off ~= 1) then

		local extra = "";
		if (PeggleData.settings.soundVolume == 1) then
			extra = "q_";
		end
		
		if (type(soundID) == "number") then
			PlaySoundFile(const.soundPath .. extra .. const.sounds[soundID]);
		else
			PlaySoundFile(const.soundPath .. extra .. soundID);
		end

	end

end

local function ReclaimObject(obj)
	obj.animated = nil;
	if (obj.isPeg) then
		tinsert(animator.pegQueue, obj);
	else
		tinsert(animator.brickQueue, obj);
	end
--	obj:Hide();
end

local function FillPolyTable(obj, usePolyTable)

	local poly = usePolyTable or const.polygon[const.curvedBrick[obj.radius]];

	local vertexSeg, rotX, rotY
	
	-- Grab our pre-defined values for faster lookups
--	local angle = mod(floor(obj.rotation + 360 - 135), 360)
--	local cos = animator.tableCos[angle];
--	local sin = animator.tableSin[angle];
--	local angle = mod(obj.rotation + 360), 360)
	local cos = cos(rad(obj.rotation - 135)); --animator.tableCos[angle];
	local sin = sin(rad(obj.rotation - 135)); --animator.tableSin[angle];

	for vertexSeg = 1, #poly, 2 do 

		-- Rotate polygon vertices
		rotX = cos * poly[vertexSeg] - sin * poly[vertexSeg + 1];
		rotY = sin * poly[vertexSeg] + cos * poly[vertexSeg + 1];

		-- Translate the polygon to top of the object
		const.polyTable[vertexSeg] = rotX + obj.x
		const.polyTable[vertexSeg+1] = rotY + obj.y

	end

	-- Set the end of the polygon data
	const.polyTable[#poly + 1] = nil;

	return #poly;
	
end

local function FromBase70(baseString, canBeNegative)

	local returnValue = 0;
	local i, value;
	local j = #baseString - 1;

	-- Pull out the base 70 data and convert it to our base 10 goodness
	for i = 1, #baseString do
		value = byte(baseString, i);
		if (value >= 96) then
			value = value - 96;
		else
			value = value - (48 - 27)
		end
		returnValue = returnValue + (value * (70^(j)));
		j = j - 1;
	end

	-- If this can be a negative number, subtract (70^size)/2 from the
	-- value so that we have the proper signage and value.
	if (canBeNegative == true) then
		returnValue = returnValue - floor((70^#baseString)/2);
	end

	return returnValue;

end

local function DeserializeLevel(sequence)

	local startTime = GetTime();

	local obj, data;
	local i = 2;

	-- Get and set the level background
	bgIndex = FromBase70(sub(sequence, 1, 1));

	-- Start with a fresh objects array (this is wasteful memory use, but this is 
	-- reclaimed at the end of this function because a lot of garbage will be generated)
	objects = {};

	while (i < #sequence) do 

		obj = {};

		-- Grab the object type and animation type
		data = FromBase70(sub(sequence, i, i));
		obj.animationType = mod(data, 10);
		obj.objectType = floor(data / 10);

		-- Grab the x and y coordinates
		obj.x = FromBase70(sub(sequence, i+1, i+3), true) / 10
		obj.y = FromBase70(sub(sequence, i+4, i+6), true) / 10

		-- Update our index
		i = i + 7;

		-- If we have a brick, we grab the radius and rotation data next.
		if (obj.objectType == OBJ_CURVED_BRICK) or (obj.objectType == OBJ_BRICK) then
			data = FromBase70(sub(sequence, i, i+2));
			obj.radius = floor(data / 1000) - 100;
			obj.rotation = data - ((obj.radius + 100) * 1000);
			i = i + 3;
		else
			obj.radius = 60;
			obj.rotation = 0;
		end

		-- If we have animation, grab the animation data as well.
		if (obj.animationType ~= const.ANI_NONE) then
			
			-- Grab the animation time, divided by 10 to get the .1 through .9 to transfer properly.
			obj.time = FromBase70(sub(sequence, i, i+1)) / 10;

			-- Calculate the on/off state of the animation and if it's a reverser and store it with
			-- the time offset value. Time offset is multiplied by 4 so we can be 0.25 second offsets,
			-- and then multiplied by 10 so the 0-9 values of the number are reserved for the
			-- animation and reverser on states.

			data = FromBase70(sub(sequence, i+2, i+3));
			local activeAndReverser = mod(data, 10);
			if (activeAndReverser > 1) then
				obj.reverser = true;
			end
			if (activeAndReverser == 1) or (activeAndReverser == 3) then
				obj.active = true;
			end
			obj.timeOffset = (data - activeAndReverser) / 10 / 4;
			i = i + 4;

			-- Grab the startX and startY (or x Radius and y Radius) for an animation.
			-- We divide by 10 to get the .1 through .9 to tranfer properly
			obj.value1 = FromBase70(sub(sequence, i, i+2), true) / 10
			obj.value2 = FromBase70(sub(sequence, i+3, i+5), true) / 10
			i = i + 6;

			-- Grab the endX and endY (or start angle and end angle) for an animation.
			-- We divide by 10 to get the .1 through .9 to tranfer properly
			obj.value3 = FromBase70(sub(sequence, i, i+2), true) / 10
			obj.value4 = FromBase70(sub(sequence, i+3, i+5), true) / 10
			i = i + 6;
		else
			obj.animationType = 0;	
			obj.value1 = 0;
			obj.value2 = 0;
			obj.value3 = 0;
			obj.value4 = 0;
			obj.reverser = true;
			obj.active = true;
			obj.time = 1;
			obj.timeOffset = 0;
		end

		-- Add our new object to the object array
		tinsert(objects, obj);

--[[
		obj.Update = editWindow.Object_Update;

		-- Add art to our object.
		if (obj.objectType == OBJ_PEG) then
			obj.art = SpawnPeg(obj.x, obj.y);
		elseif (obj.objectType == OBJ_CURVED_BRICK) then
			obj.art = SpawnBrick(obj.x, obj.y, obj.radius);
		elseif (obj.objectType == OBJ_BRICK) then
			obj.art = SpawnBrick(obj.x, obj.y, 0);
		end

		obj:Update();
--]]
	end

--	collectgarbage();

end

local function ToBase70(value, totalSize, canBeNegative)
	
	local subValue;
	local returnValue = "";

	-- If this value can be negative, we add the value to
	-- 70^totalSize / 2 so we have a digit from -(70^totalSize)/2
	-- to (70^totalSize)/2, effectively signing it.
	if (canBeNegative == true) then
		value = value + floor((70^totalSize)/2);
	end

	-- Go through the number and break it down into base 70
	while true do 
		subValue = mod(value, 70);
		if (subValue < 27) then
			returnValue = char(96+subValue) .. returnValue;
		else
			returnValue = char(48+(subValue-27)) .. returnValue;
		end
		if (value >= 70) then
			value = floor(value / 70);
		else
			break;
		end
	end

	-- Ensure the string is exactly the size we requested. An example: If we
	-- provided the number 1 and the string needs to be 3 characters long, we'll
	-- get ``a, where ` is 0 and a is 1, due to our code.
	if (#returnValue < totalSize) then
		returnValue = string.rep(char(96), (totalSize - #returnValue)) .. returnValue;
	end

	return returnValue;

end

local function DataCheck(data, seed)
	local size, value, i;
	local oddCount = seed or 0;
	local evenCount = seed or 0;
	local check1, check2, check3, check4, check5;
	size = #data;
	for i = 1, size do
		value = byte(data, i);
		if (mod(i, 2) == 0) then
			evenCount = evenCount + value;
		else
			oddCount = oddCount + value;
		end
	end
	check1 = mod(evenCount, 10);
	check2 = mod(evenCount - check1, 100) / 10;
	check3 = mod(oddCount, 10);
	check4 = mod(oddCount - check3, 100) / 10;
	check5 = mod(check1+check2+check3+check4, 10);
	return check1, check2, check3, check4, check5
end

-- Seed is used as a byte count of every letter in the users' name.
-- For example, if the player's name is "RST", the seed would be: 82 + 83 + 84 = 249
-- The seed is passed to the DataPack and DataUnpack functions
--
-- Typical idea for data string (what is in the data string):
--
-- Player's own score: score (seed is player's name)
-- Player sending score: score (seed is player's name)
-- Player receiving score: score (seed is sending player's name)
-- Challenge mode scores (saved): (length of name + score) x number of players + name x number of players (seed is sending player's name)

local function DataPack(data, seed)
	local seed = seed or 0;
	local check1, check2, check3, check4, check5 = DataCheck(data, seed);
	return ToBase70(100000+check5*10000+check4*1000+check3*100+check2*10+check1, 3) .. data;
end

local function DataUnpack(packedData, seed)

	-- Ignore invalid data
	if (type(packedData) ~= "string") or (#packedData < 4) then
		return;
	end

	-- The first three bytes are the data checking bytes.
	local dataCheck = sub(packedData, 1, 3);
	local data = sub(packedData, 4);

	seed = seed or 0;
	
	-- Get the real check bytes and compare to given.
	local check1, check2, check3, check4, check5 = DataCheck(data, seed);
	local given1, given2, given3, given4, given5;
	local dumpVal = tostring(FromBase70(dataCheck));
	given1 = tonumber(sub(dumpVal, 6, 6));
	given2 = tonumber(sub(dumpVal, 5, 5));
	given3 = tonumber(sub(dumpVal, 4, 4));
	given4 = tonumber(sub(dumpVal, 3, 3));
	given5 = tonumber(sub(dumpVal, 2, 2));

	-- return unpacked data if valid,
	-- return nil is invalid.
	if ((given1 == check1) and (given2 == check2) and (given3 == check3) and (given4 == check4) and (given5 == check5)) then
		return data;
	end

end

local function SeedFromName(name)
	local i, seed = 0, 0;
	for i = 1, #name do 
		seed = seed + byte(name, i);
	end
	return seed;
end

-- Builds a fresh player data string, with random garbage thrown in
-- to keep people on their toes >:)

local function RebuildPlayerData()
	local i;
	local data = "";
	for i = 1, 12 do 
		data = data .. char(random(48, 90)) .. char(random(48, 90)) .. char(random(48, 90)) .. char(random(48, 90))
	end
	data = ToBase70(1000000000000, 7) .. data .. ToBase70(100000000000, 7) .. ToBase70(1000000000000, 7);
	playerData[DATA] = DataPack(data, SeedFromName(localPlayerName))
	return data;
end

local function Talents_GetTotalTalentPoints()

	local data = DataUnpack(playerData[DATA], SeedFromName(localPlayerName))
	if not data then
		data = RebuildPlayerData();
	end

	local levelData = tostring(FromBase70(sub(data, 1, 7)));
	local totalPoints = 0;
	local i;
	local notCleared = 48;
	local clearFlag;
	local stageClear, stageFullClear = 0, 0;
	for i = 2, #levelData do 
		clearFlag = byte(levelData, i) - 49;
		if (clearFlag > 0) and (clearFlag < 3) then
			totalPoints = totalPoints + clearFlag;
			if (clearFlag == 1) then
				stageClear = stageClear + 1;
			else
				stageClear = stageClear + 1;
				stageFullClear = stageFullClear + 1;
			end
		end
	end
	return totalPoints, stageClear, stageFullClear;
	
end

local function Talents_GetUsedTalentPoints()

	local data = DataUnpack(playerData[DATA], SeedFromName(localPlayerName))
	if not data then
		data = RebuildPlayerData();
	end

	local talentString = tostring(FromBase70(sub(data, 7 + 12*4 + 1, 7 + 12*4 + 7)));
	local usedPoints = 0;
	local zero = 48;
	for i = 2, #talentString do 
		talentData[33 + i - 1] = (byte(talentString, i) - zero);
		usedPoints = usedPoints + talentData[33 + i - 1]
	end

	return usedPoints;

end

local function Talents_GetTalentPointInfo()
	local usedPoints = Talents_GetUsedTalentPoints();
	local totalPoints = Talents_GetTotalTalentPoints();
--	if (PeggleData.talentCheat == true) then
--		totalPoints = 24;
--	end
	local freePoints = totalPoints - usedPoints;
	local sparks = window.sparks;
	if (freePoints > 0) then
		sparks:Show();
	else
		sparks:Hide();
	end
	return freePoints, usedPoints, totalPoints;
end

local function Talents_GetTalentInfo(id)
	local currentRank = talentData[33 + id];	
	local tier =  talentData[(id - 1) * 3 + 1];
	local maxRank = talentData[(id - 1) * 3 + 2];
	local prereq = talentData[(id - 1) * 3 + 3];
	return currentRank, maxRank, tier, prereq;
end

local function Talents_UpdateDisplay()

	local frame = window.catagoryScreen.frames[4];
	local freePoints, usedPoints, totalPoints = Talents_GetTalentPointInfo();

	frame.pointsLeft:SetText(const.locale["_POINTS_LEFT"] .. ": |cFFFFFFFF" .. freePoints);

	local i, tier, maxRank, prereq, currentRank, r, g, b, obj;
	local group = frame.tree.node;

	for i = 1, #group do 

		currentRank, maxRank, tier, prereq = Talents_GetTalentInfo(i);

		obj = group[i];
		obj.rank:SetText(currentRank);

		-- First, if it is maxed out in rank, show it
		if (currentRank == maxRank) then
			r, g, b = 1, 0.82, 0;

		-- Or, if it is not maxed out, see if we can assign
		-- stuff to it
		elseif (usedPoints >= tier * 5) then
			r, g, b = 0, 1, 0;

		-- Otherwise, it's disabled
		else
			r, g, b = 0.5, 0.5, 0.5;
		end

		-- If it has a prereq, is it on?
		if (prereq > 0) then
			if (talentData[33 + prereq] > 4) and (((usedPoints >= tier * 5) and (freePoints > 0)) or (currentRank > 0)) then
				group[prereq].arrow:SetTexCoord(unpack(TALENT_BRANCH_TEXTURECOORDS.down[1]));
				obj.arrow:SetTexCoord(unpack(TALENT_ARROW_TEXTURECOORDS.top[1]));
			else
				r, g, b = 0.5, 0.5, 0.5;
				group[prereq].arrow:SetTexCoord(unpack(TALENT_BRANCH_TEXTURECOORDS.down[-1]));
				obj.arrow:SetTexCoord(unpack(TALENT_ARROW_TEXTURECOORDS.top[-1]));
			end
		
		end

		if (freePoints == 0) and (currentRank == 0) then
			r, g, b = 0.5, 0.5, 0.5;
		end

		if (r == 0.5) then
			SetDesaturation(obj.icon, true);
			getglobal(obj.rank:GetName() .. "Border"):Hide();
			obj.rank:Hide();
			obj.border:SetVertexColor(r, g, b);
		else
			SetDesaturation(obj.icon, false);
			getglobal(obj.rank:GetName() .. "Border"):Show();
			obj.rank:Show();
			obj.rank:SetVertexColor(r, g, b);
			obj.border:SetVertexColor(r, g, b);
		end
				
	end

end

local function Talents_AssignTalent(self)
	local freePoints, usedPoints, totalPoints = Talents_GetTalentPointInfo();
	local id = self:GetID();
	if (freePoints > 0) then

		local tier = talentData[(id - 1) * 3 + 1];
		local maxRank = talentData[(id - 1) * 3 + 2];
		local prereq = talentData[(id - 1) * 3 + 3];
		local currentRank = talentData[33 + id];

		-- Make sure the tier's minimum points are met
		if (usedPoints >= (tier * 5)) then

			-- Make sure this talent isn't maxed out
			if (currentRank < maxRank) then

				-- If there is a prereq, make sure it exists
				if ((prereq == 0) or (talentData[33 + prereq] > 4)) then

					local data = DataUnpack(playerData[DATA], SeedFromName(localPlayerName))
					if not data then
						data = RebuildPlayerData();
					end
					
					-- If we're here, that means we can add the point.
					-- Add it and then update the count on the button.
					currentRank = currentRank + 1;
					talentData[33 + id] = currentRank;

					-- Save the talent point
					local newTalentData = 100000000000;
					local i;
					for i = 1, 11 do 
						newTalentData = newTalentData + (talentData[33 + i] * (10 ^ (11 - i)));
					end

					playerData[DATA] = DataPack(string.sub(data, 1, 7 + 12*4) .. ToBase70(newTalentData, 7) .. string.sub(data, 7 + 12*4 + 8), SeedFromName(localPlayerName));

					Talents_UpdateDisplay();

					self:GetScript("OnEnter")(self)

				end
			end
			
		end

	end
end

local function ServerScore(scoreData, isReceiving)

	local stageClears, stageFullClears, playerData;
	local return1, return2, return3, return4;
	if (isReceiving) then
		local value = FromBase70(sub(scoreData, 1, 2)) - 1;
--[[
		stageClears = mod(value, 100);
		value = (value - stageClears) / 100;
		if (value >= 30) then
			stageFullClears = value - 30;
			playerData = 2;
		else
			stageFullClears = value - 10;
			playerData = 1;
		end
--]]
--		return1 = playerData;
--		return2 = stageClears;
--		return3 = stageFullClearsl;
--		return4 = FromBase70(scoreData, 3);
		return1 = value;
		return2 = FromBase70(sub(scoreData, 3));
	else
		_, stageClears, stageFullClears = Talents_GetTotalTalentPoints();
		playerData = ToBase70(stageClears + ((specialType * 20 + 10 + stageFullClears) * 100) + 1, 2);
		return1 = DataPack(playerData .. ToBase70(scoreData, 4), SeedFromName(const.name));
		--printd(playerData);
		--printd(return1);
		--printd(DataPack(playerData .. ToBase70(scoreData, 4), SeedFromName(const.name)));
	end

	return return1, return2;
	
end

-- The score table is only used for faster score placement on the various screens
-- and is not actually used to build the score data. Instead, the score data for
-- the player is based upon the existing score data is saved. We verify that the
-- score data is correct before we insert the level information. If the player
-- tries to fake some data, we will wipe their profile of this information (since
-- it is corrupted) and drop new data in place. Sucks to the them.

local function InsertScoreData(score, levelID, flagData)

	-- First, verify the data that we have. If it's incorrect, sucks to be
	-- the player as their data is now wiped clean.

	local i;
	local data = DataUnpack(playerData[DATA], SeedFromName(localPlayerName))
	if not data then
		data = RebuildPlayerData();
	end
	local flagUpdate

	if (score) then

		local newLevelFlags = sub(data, 1, 7);
		local updateScore;
		if (flagData ~= 0) then

			local flag = tostring(flagData);
			local levelFlags = tostring(FromBase70(newLevelFlags));

			-- Only update the flag if it is better than what was already there.
			
			local currentFlag = byte(levelFlags, levelID + 1) - 48
			if (currentFlag == 0) then
				updateScore = true;
			end
			if (currentFlag < flagData) then
				flagUpdate = flagData - 1;
				if (levelID == 1) then
					newLevelFlags = ToBase70(tonumber("1" .. flag .. sub(levelFlags, 3)), 7);
				elseif (levelID == 12) then
					newLevelFlags = ToBase70(tonumber("1" .. sub(levelFlags, 2, levelID) .. flag), 7);
				else
					newLevelFlags = ToBase70(tonumber("1" .. sub(levelFlags, 2, levelID) .. flag .. sub(levelFlags, levelID + 2)), 7)
				end
				scoreData[levelID + 12] = flagData
			end

		end

		-- Now, update the score
		local levelScores = sub(data, 8);
		local currentScore = FromBase70(sub(levelScores, (levelID - 1) * 4 + 1, levelID * 4));
		if (score > currentScore) or (updateScore) then
			if (levelID == 1) then
				levelScores = ToBase70(score, 4) .. sub(levelScores, 5);		
			else
				levelScores = sub(levelScores, 1, (levelID - 1) * 4) .. ToBase70(score, 4) .. sub(levelScores, levelID * 4 + 1);
			end
			scoreData[levelID] = score;
		end

		-- Dump it
		playerData[DATA] = DataPack(newLevelFlags .. levelScores, SeedFromName(localPlayerName));

		if (window.duelStatus == 3) then
			local frame = window.catagoryScreen.frames[2];

			local _, stageClears, stageFullClears = Talents_GetTotalTalentPoints();
			local playerData = ToBase70(stageClears + ((specialType * 20 + 10 + stageFullClears) * 100) + 1, 2)
			playerData = playerData .. ToBase70(totalScore, 4) .. ToBase70(const.stats[4], 4) .. ToBase70(const.stats[5], 4) .. ToBase70(const.stats[6], 4);
			local finalData = DataPack(playerData, SeedFromName(const.name));

			frame.player1.value1 = const.stats[4];
			frame.player1.value2 = const.stats[6];
			frame.player1.value3 = const.stats[5];
			frame.player1.value4 = specialType + 1;
			frame.player1.value5 = stageClears;
			frame.player1.value6 = stageFullClears;
			frame.player1.value = totalScore;
			SendAddonMessage(window.network.prefix, const.commands[6] .. "+" .. finalData, "WHISPER", frame.name2:GetText());

--			frame.result1:SetText(NumberWithCommas(totalScore));
--			frame.result1.temp = totalScore;
			frame:UpdateWinners();
			if (PeggleData.settings.closeDuelChallenge == true) then
				window.duelStatus = nil;
				window:Hide();
			end
		end

	end

	return flagUpdate;

end

local function UpdateChallengeScore(totalPoints, theChallenge)
	local challenge = theChallenge or const.extraInfo;
	local data = DataUnpack(challenge[DATA], SeedFromName(challenge.creator));
	local data2;
	local playerID = Peggle.TableFind(challenge.names, const.name);
	if (playerID) then
		if (data) then
			if (totalPoints) then
				challenge.played = true;
				challenge.new = nil;
				data2 = ServerScore(totalPoints);
				data = DataPack((sub(data, 1, 68 + (playerID - 1) * 6) .. sub(data2, 4) .. sub(data, 69 + playerID * 6)), SeedFromName(challenge.creator));
				challenge[DATA] = data;
			else
				data2 = sub(data, 69 + (playerID - 1) * 6, 68 + playerID * 6)
			end

			--printd("Updating score");
			if (challenge.serverName) then
				SendAddonMessage(window.network.prefix, const.commands[19] .. "+" .. challenge.id .. "+" .. data2, "WHISPER", challenge.serverName);
			end
		else
			print(const.locale["_PEGGLE_ISSUE1"]);
		end
	end
end

-- Simply returns the row and column in the gameObjectDB that the
-- x and y coordinate maps to. Used in lots of areas.
local function GameObjectCoordLocation(x, y)
	local xLoc = floor(x / const.sectionXSize) + 1;
	local yLoc = floor(y / const.sectionYSize) + 1;
	if (xLoc < 1) or (xLoc > const.boardXYSections) then
		xLoc, yLoc = nil, nil;
	elseif (yLoc < 1) or (yLoc > const.boardXYSections) then
		xLoc, yLoc = nil, nil;
	end
	return xLoc, yLoc;
end

local function GameObjectInsert(obj, i, j)
	
	-- All objects need to have x and y locations, which is how we add
	-- them to the section that stores them (for faster game object checking
	-- when the balls move around)

	if not i then
		i, j = GameObjectCoordLocation(obj.x, obj.y)
	end

	-- If it is out of range to be added to the game board, leave now.
	if (i == nil) then
		return
	end

	-- If this object already exists in this section, we don't add it
	-- and just exit the function

	local k;
	for k = 1, #gameObjectDB[j][i] do 
		if (obj == gameObjectDB[j][i][k]) then
			return;
		end
	end
	
	tinsert(gameObjectDB[j][i], obj);

end

local function GameObjectRemove(obj, i, j)
	
	-- If i and j are specified, we know where to remove the object from.
	-- Otherwise, figure it out via the x and y coordinates of the object

	if not i then
		i, j = GameObjectCoordLocation(obj.x, obj.y)
	end

	if not i then
		return;
	end

	-- If we found the object, remove it
	local k;
	for k = 1, #gameObjectDB[j][i] do 
		if (obj == gameObjectDB[j][i][k]) then
			tremove(gameObjectDB[j][i], k);
			return;
		end
	end

end

local function UpdateMove_Line(obj)

--	local phasePercent = (sin(fullCircle * obj.elapsed / obj.loopTime) + 1) / 2;
--	local xChange = obj.startX - obj.endX;
--	local yChange = obj.startY - obj.endY;

--	obj.x = obj.startX - phasePercent * xChange;
--	obj.y = obj.startY - phasePercent * yChange;

	local phasePercent
	if (obj.reverser) then
		phasePercent = 1 - (cos(2 * math.pi * obj.elapsed / obj.loopTime) + 1) / 2;
	else
		phasePercent = obj.elapsed / obj.loopTime;
	end

	local xChange;
	local yChange;

	if (obj.value4) and (obj.value4 > 0)  then
		xChange = obj.value4 * -cos(rad(obj.value3));
		yChange = obj.value4 * -sin(rad(obj.value3));
	else
		xChange = obj.startX - obj.value1;
		yChange = obj.startY - obj.value2;
	end

	obj.x = obj.startX - phasePercent * xChange;
	obj.y = obj.startY - phasePercent * yChange;

end

local function UpdateMove_Circle(obj)

--	local offsetX = cos(fullCircle * obj.elapsed / obj.loopTime) * obj.moveRadius;
--	local offsetY = sin(fullCircle * obj.elapsed / obj.loopTime) * obj.moveRadius;

--	obj.x = obj.startX + offsetX;
--	obj.y = obj.startY + offsetY;

--	local offsetX = cos(fullCircle * obj.elapsed / obj.loopTime) * obj.value1;
--	local offsetY = sin(fullCircle * obj.elapsed / obj.loopTime) * obj.value2;
	local offsetX = cos(rad(360 * obj.elapsed / obj.loopTime)) * (obj.value1 + (20-3)/2) * 0.85;
	local offsetY = sin(rad(360 * obj.elapsed / obj.loopTime)) * (obj.value2 + (20-3)/2) * 0.85;

	obj.x = obj.startX + offsetX;
	obj.y = obj.startY + offsetY;

end

local function UpdateRotation(obj)

--	local angle = mod(floor(obj.elapsed / obj.loopTime * 360) + 135, 360);
--	animator:RotateTexture(obj.texture, angle, 0.5, 0.5)
--	obj.rotation = angle;

	if (obj.isBrick == true) then	
		obj.rotation = mod(obj.elapsed / obj.loopTime * 360 + 135, 360);
--		local angle = mod(floor(obj.elapsed / obj.loopTime * 360) + 135, 360);
		animator:RotateTexture(obj.texture, floor(obj.rotation), 0.5, 0.5)
	end

end

local function UpdateMover(self, obj, elapsed)

	if (obj.moveType > 0) then

		-- Update the elapsed time for the object
		obj.elapsed = obj.elapsed + elapsed;
		if (obj.elapsed > obj.loopTime) then
			obj.elapsed = mod(obj.elapsed, obj.loopTime);
		end

		-- Grab it's present location on the game board tree
		local oldX, oldY = GameObjectCoordLocation(obj.x, obj.y);

		-- straight line
		if (obj.moveType == const.ANI_LINE) then
			UpdateMove_Line(obj);
			
		-- circle
		elseif (obj.moveType == const.ANI_CIRCLE) then
			UpdateMove_Circle(obj);

		-- rotator
		elseif (obj.moveType == const.ANI_ROTATOR) then
			UpdateRotation(obj);

		-- straight line rotator
		elseif (obj.moveType == const.ANI_LINE_ROTATOR) then
			UpdateMove_Line(obj);
			UpdateRotation(obj);
			
		-- circle rotator
		elseif (obj.moveType == const.ANI_CIRCLE_ROT) then
			UpdateMove_Circle(obj);
			UpdateRotation(obj);
		end

		-- Grab the new location on the game board tree. If it
		-- is different than the old location, we need to update
		-- it in the tree.
		local newX, newY = GameObjectCoordLocation(obj.x, obj.y);
		if (newX ~= oldX) or (newY ~= oldY)  then
			if (oldX) then
				GameObjectRemove(obj, oldX, oldY);
			end
			GameObjectInsert(obj, newX, newY);
		end

		-- Set it to the new location on screen
		obj:SetPoint("Center", gameBoard, "Bottomleft", obj.x, obj.y);

		-- Non-active pieces are only set to their initial locations
		-- with % into time offsets.
		if obj.inactive then
			obj.moveType = 0;
			obj.inactive = nil;
		end

	end

end

local function Shoot(self, button)
--[[
	if (IsControlKeyDown()) and (IsAltKeyDown()) and (IsShiftKeyDown()) then
		local x, y = GetCursorPosition();
		local left, bottom, width, height = self:GetRect()
		local scale = self:GetEffectiveScale();
		local x2, y2;
		x2 = x / scale - left;
		y2 = y / scale - bottom;
		animator:SpawnBall(x2, y2, 0, 0);
		return
	end
--]]

	if (button == "RightButton") and ((shooterReady == true) or (feverPegsHit >= feverPegsTotal)) then
		const.speedy = true;
		return;
	end

	if (shooterReady == false) or (window.charScreen:IsShown()) or (window.summaryScreen:IsShown()) or (window.gameMenu:IsShown())  then -- or (window.feverTracker.barFlashUpdate) or (window.roundPegs.elapsed) then
		return;
	end

--	end

	if (window.roundBalls.elapsed < 3.2) then
		window.roundBalls.elapsed = 3.2;
	end

	const.speedy = nil;

	shooterReady = false;
	ballCount = ballCount - 1;
	window.ballTracker.ballDisplay:SetText(ballCount);

	local x, y;

	x = 64 * cos(rad(ANGLE));
	y = 64 * sin(rad(ANGLE));

	x = (const.boardWidth / 2) + 1
	y = (const.boardHeight - 16) - 20

	Sound(const.SOUND_SHOT);

--	animator:SpawnBall(const.boardWidth/2 + x, const.boardHeight - (88 - 70) + y, ANGLE, SHOOT_FORCE);
	animator:SpawnBall(x, y, ANGLE, SHOOT_FORCE);

	animator:SpawnParticleGen(x, y+4, 0.2, 0.3, .005, SHOOTER_ANGLE - 1, SHOOTER_ANGLE + 1, 10, 13, 0, "spark", 1, 1, 0.8)

	for x = 1, 10 do
		gameBoard.trail[x]:Hide();
	end

	const.stats[1] = const.stats[1] + 1;

	window.shooter.ball:Hide();

	for x = 1, numLines do
		getglobal("polyLine"..x):Hide();
	end
	for x = 1, numPathPieces do
		getglobal("pathPiece"..x):Hide();
	end

	specialInPlay = nil;
	if (specialCount > 0) then
		specialInPlay = true;
		specialCount = specialCount - 1;
		if (specialCount == 0) then
			GUIDE_HITS = 1;
			window.powerLabel:Hide();
		end
	end

	showGuide = nil;
	if (specialCount > 0) and (specialType == SPECIAL_GUIDE) then
		showGuide = true;
		window.powerLabel.text:SetText(const.locale["_SPECIAL_NAME1"] .. " " .. specialCount);
	end

	local pegsInPlay = feverPegsTotal - feverPegsHit;
	orangeAttackCount = -30;
	for x = 1, #const.ranks, 2 do 
		if (pegsInPlay >= const.ranks[x]) then
			orangeAttackCount = -const.ranks[x+1];
		end
	end

	slideComboCount = 0;

	lastPeg = nil;

end

local function ReclaimPegs()

	local i, j, k, index, obj;
	local db = animator.animationStack;
	local purpleCount = 0;
	local giveGreen = 0;
	roundOver = true;
	local colorBlind = "";

	index = 1;

	colorBlind = "";
	if (PeggleData.settings.colorBlindMode) then
		colorBlind = "_";
	end

	for i = 1, #db do 
		obj = db[index];

		-- if it was a score piece, remove the score status so we can
		-- transfer it elsewhere. This is done here so that any purples
		-- that are off the screen can be reclaimed as well.
		if (obj.id == PEG_PURPLE) then
			purpleCount = purpleCount + 1;
			obj.id = PEG_BLUE;
			if (obj.isPeg) then
				obj.texture:SetTexCoord(0 + ((PEG_BLUE - 1) * 0.25), (PEG_BLUE * 0.25),0,0.5);
			else
				obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_BLUE] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
			end
		end

		if (obj.hit == true) then
			if (specialInPlay == 1) and (obj.id == PEG_GREEN) and (talentData[33 + 10] == 1) then
				giveGreen = giveGreen + 1;
			end
--			ReclaimObject(tremove(db[j][i], index))
			GameObjectRemove(obj);
			ReclaimObject(tremove(db, index))
		else
			index = index + 1;	
			if (obj.required == true) then
				if (feverPegsHit == (feverPegsTotal-1)) then
					animator.lastPeg = obj;
				end
				roundOver = false;
			end
		end
	end

	db = gameObjectDB;

	-- Go, go through all in-game objects to see if any purples exist.
	for j = 1, #db do 
		for i = 1, #db[j] do 
			for k = 1, #db[j][i] do 
				obj = db[j][i][k];
				if (obj.id == PEG_PURPLE) then
					purpleCount = purpleCount + 1;
					obj.id = PEG_BLUE;
					if (obj.isPeg) then
						obj.texture:SetTexCoord(0 + ((PEG_BLUE - 1) * 0.25), (PEG_BLUE * 0.25),0,0.5);
					else
						obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_BLUE] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
					end
				end
				if (obj.id == PEG_BLUE) then
					tinsert(availablePegs, obj);
				end
			end	
		end
	end

	-- Now, if redistribute the purples.
	for i = 1, purpleCount + giveGreen do 

		-- If we have pegs left to pick from (blue ones), continue
		if (#availablePegs > 0) then

			-- Pick a random blue peg from the list and make it a purple one
			obj = tremove(availablePegs, random(1, #availablePegs));
			if (i <= giveGreen) then
				obj.id = PEG_GREEN;
			else
				obj.id = PEG_PURPLE;
			end

			if (obj.isPeg) then
				obj.texture:SetTexCoord(0 + ((obj.id  - 1) * 0.25), (obj.id  * 0.25),0,0.5);
			else
				obj.texture:SetTexture(const.artPath .. const.brickTex[obj.id ] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
			end
				
		end
	end

	table.wipe(availablePegs);

	if (roundOver == true) and (gameOver == false) then
		recent = "r" .. "ec" .. "ent";
		gameOver = true;
--		totalScore = totalScore + ballCount * 10000;
--		const.stats[5] = const.stats[5] + ballCount * 10000
		currentScoreText:SetText(NumberWithCommas(totalScore));
		playerData[recent][bgIndex] = totalScore;
		local flag = 2;
		if (const.stats[3] == const.stats[7]) then
			flag = 3;
		end

		local firstFlag = InsertScoreData(totalScore, bgIndex, flag);
		animator.temp1 = firstFlag
		animator.temp2 = flag;

		if (const[const.newInfo[11]]) then
			window.network:Send(const.commands[21], const[const.newInfo[11]] .. "+" .. DataPack(ToBase70(totalScore, 4), SeedFromName(const.name)), "WHISPER", const[const.newInfo[11] .. 4])
			if not const[const.newInfo[12]] then
				const[const.newInfo[11]] = nil;
			end
		elseif (const.extraInfo) then
			UpdateChallengeScore(totalScore);
		end
	end

end

local function Generate(sequence, challenge, duel, peggleLoot)

	currentLevelString = sequence;

	const.extraInfo = challenge;

	gameOver = false;
	const.speedy = nil;
	
	gameBoard.fineX = nil;
	gameBoard.fineY = nil;

	animator.feverUp = nil;
	animator.temp1 = nil;
	animator.temp2 = nil;

	window.bonusBar1:Hide();
	window.bonusBar2:Hide();
	window.bonusBar3:Hide();
	window.bonusBar4:Hide();
	window.bonusBar5:Hide();
	window.catcher:Show();
	window.catcherBack:Show();
	window.catcher:SetAlpha(1);

	window.fever1:Hide();
	window.fever2:Hide();
	window.fever3:Hide();
	window.feverPegScore:Hide();

	window.rainbow:Hide();

	window.roundPegs.elapsed = nil;
	window.roundPegs:Hide();
	window.roundPegScore:Hide();
	window.roundBonusScore:Hide();
	window.roundPegs:SetAlpha(1);
	window.roundPegScore:SetAlpha(1);
	window.roundBonusScore:SetAlpha(1);

	window.powerLabel:Hide();

	window.banner:Hide();
	window.banner.tex:Hide();

--	local testCurvedBricks = true;
--	local testPegs = true;
--	local testSlide = true;

	local i, j, k, obj;
	local highScore = window.bestScore;

	-- Remove all active game objects
	for j = 1, #gameObjectDB do 
		for i = 1, #gameObjectDB[j] do 
			for k = 1, #gameObjectDB[j][i] do 
--				ReclaimObject(tremove(gameObjectDB[j][i], 1));
				tremove(gameObjectDB[j][i], 1);
			end	
		end
	end

	-- Remove all animation objects
	for j = 1, #animator.animationStack do 
		obj = tremove(animator.animationStack, 1);
		ReclaimObject(obj);
		obj:Hide();
	end

	-- Remove all active balls
	for i = 1, #animator.activeBallStack do 
		obj = tremove(animator.activeBallStack, 1);
		obj.animated = nil;
		tinsert(animator.ballQueue, obj);
		obj:Hide();

		for j = 1, 30 do 
			obj["trail" .. j]:Hide();
		end
--]]
	end
	
	-- Remove all floating text and reclaim them
	for i = 1, #animator.activePointTextStack do 
		obj = tremove(animator.activePointTextStack, 1);
		obj:Hide();
		tinsert(animator.pointTextQueue, obj);
	end

	-- Remove all particle generators
	for j = 1, #animator.activeParticleGens do 
		obj = tremove(animator.activeParticleGens, 1);
		tinsert(animator.particleGenQueue, obj);
	end

	-- Remove all particles
	for j = 1, #animator.activeParticles do 
		obj = tremove(animator.activeParticles, 1);
		obj:Hide();
		tinsert(animator.particleQueue, obj);
	end

	-- Hide the trails
	for i = 1, 10 do 
		gameBoard.trail[i]:Hide();
	end

	-- Hide any paths in play
	for i = 1, numLines do 
		getglobal("polyLine"..i):Hide();
	end
	for i = 1, numPathPieces do 
		getglobal("pathPiece"..i):Hide();
	end

	-- Remove all hit pegs (no need to reclaim)
	for i = 1, #animator.hitPegStack do 
		tremove(animator.hitPegStack, 1);
	end

	-- Reset the ball loader
	for i = 1, #window.ballTracker.ballStack do 
		obj = tremove(window.ballTracker.ballStack, 1);
		obj:Hide();
		tinsert(window.ballTracker.ballQueue, obj);
	end
--[[
	["x"] = 0,				-- byte 2-4
	["y"] = 0,				-- byte 5-7
	["objectType"] = OBJ_PEG,		-- byte 1, x0, x1, x2
		["radius"] = 80,			-- byte 8
		["rotation"] = 0,			-- byte 9-10
	["animationType"] = const.ANI_NONE,		-- byte 1, 0x, 1x, 2x, 3x, 4x, 5x
		["value1"] = 0,				-- byte 15-17
		["value2"] = 0,				-- byte 18-20
		["value3"] = 0,				-- byte 21-23
		["value4"] = 0,				-- byte 24-26
		["active"] = true,			-- byte 11-12, xxx0, xxx2 (on, on)
		["reverser"] = true,			-- byte 11-12, xxx1, xxx2 (on, on)
		["time"] = 1,				-- byte 13-14
		["timeOffset"] = 0;			-- byte 11-12  000x to 200x (0 = 0%, 1 = 0.5%, 2.5 = 1%)
--]]

	DeserializeLevel(sequence);
	gameBoard.background:SetTexture(const.artPath .. "bg" .. bgIndex);

	local presetPegs, pegData, j
	if (challenge) then
		pegData = sub(challenge[DATA], 13 + 3, 68 + 3);
		presetPegs = {};
		for j = 1, 28 do 
			presetPegs[j] = FromBase70(sub(pegData, (j - 1) * 2 + 1, j * 2));
		end
	elseif (duel) then
		pegData = duel;
		presetPegs = {};
		for j = 1, 28 do 
			presetPegs[j] = FromBase70(sub(pegData, (j - 1) * 2 + 1, j * 2));
		end
	end

	feverPegsTotal = 0;

	local colorBlind = "";
	if (PeggleData.settings.colorBlindMode) then
		colorBlind = "_";
	end

	local loadObj;
	for i = 1, #objects do 
		loadObj = objects[i];
		if (loadObj.objectType == OBJ_PEG) then
			obj = animator:SpawnPeg(loadObj.x, loadObj.y, PEG_BLUE, 0, 0, loadObj.animationType, loadObj.time * (loadObj.timeOffset/100), loadObj.time, loadObj.value1, loadObj.value2, loadObj.value3, loadObj.value4);

			--x, y, pegType, angle, radius, moveType, elapsed, loopTime, endX, endY)
			
		elseif (loadObj.objectType == OBJ_CURVED_BRICK) then
			obj = animator:SpawnBrick(loadObj.x, loadObj.y, PEG_BLUE, loadObj.rotation, loadObj.radius, loadObj.animationType, loadObj.time * (loadObj.timeOffset/100), loadObj.time, loadObj.value1, loadObj.value2, loadObj.value3, loadObj.value4);
		elseif (loadObj.objectType == OBJ_BRICK) then
			obj = animator:SpawnBrick(loadObj.x, loadObj.y, PEG_BLUE, loadObj.rotation, 0, loadObj.animationType, loadObj.time * (loadObj.timeOffset/100), loadObj.time, loadObj.value1, loadObj.value2, loadObj.value3, loadObj.value4);
		end
		obj.reverser = loadObj.reverser;
		if not loadObj.active then
			obj.inactive = true;
		end
		animator:UpdateMover(obj, 0);
		GameObjectInsert(obj);

		-- If this is a challenge, set the board up exactly
		-- as it should be
		if (challenge) or (duel) then
			for j = 1, 28 do 
				if (i == presetPegs[j]) then

					if (j <= 25) then
						obj.id = PEG_RED;
						obj.required = true;
						feverPegsTotal = feverPegsTotal + 1;
						if (obj.isPeg) then
							obj.texture:SetTexCoord(0 + ((PEG_RED - 1) * 0.25), (PEG_RED * 0.25),0,0.5);
						else
							obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_RED] .. "Brick" .. const.curvedBrick[obj.radius]);
						end
					elseif (j < 28) then
						obj.id = PEG_GREEN;
						if (obj.isPeg) then
							obj.texture:SetTexCoord(0 + ((PEG_GREEN - 1) * 0.25), (PEG_GREEN * 0.25),0,0.5);
						else
							obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_GREEN] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
						end
					else
						obj.id = PEG_PURPLE;
						if (obj.isPeg) then
							obj.texture:SetTexCoord(0 + ((PEG_PURPLE - 1) * 0.25), (PEG_PURPLE * 0.25),0,0.5);
						else
							obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_PURPLE] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
						end
					end
				end
			end
		end

	end
	objects = nil;

	feverMultiplier = 1;
	currentScore = 0;
	roundScore = 0;
	roundScoreTalents = 0;
	bonusScore = 0;
	bonusScoreTalents = 0;
	pegsHit = 0;
	ballCount = 0;
	totalScore = 0;
	feverPegsHit = 0;
	specialCount = 0;
	freeBallCombo = 0;
	freeBallComboGet = 0;
	showGuide = nil;
	lastZoomDistance = nil;
	animator.sigh = nil;

	const.stats[1] = 0;
	const.stats[2] = 0;
	const.stats[3] = 0;
	const.stats[4] = 0;
	const.stats[5] = 0;
	const.stats[6] = 0;
	const.stats[7] = #animator.animationStack;

	GUIDE_HITS = 1;
	GAME_SPEED = 1;
	currentScoreText:SetText(pegsHit);
	animator.lastPeg = nil;
	shooterReady = false;
	highScore:SetText(NumberWithCommas(scoreData[bgIndex]));

	gameBoard:ClearAllPoints();
	gameBoard:SetPoint("center");
	gameBoard:SetScale(1);

	window.feverTracker.barFlashUpdate = nil;
	window.roundPegs.elapsed = nil;

	-- Clear the extra ball gauge and then load up 10 balls
	window.ballTracker:UpdateDisplay(3);
	if (window.ballTracker.ball) then
		window.ballTracker.ball:Hide();
		window.ballTracker.ball.loading = nil;
	end
	window.ballTracker.active = nil;
	table.wipe(window.ballTracker.actionQueue);
	window.ballTracker.fastAdd = true;
	
	local addBalls = 4 + 6;
	if (challenge) then
		addBalls = const.currentView[4];
		window.bestScoreCaption:SetText(window.bestScoreCaption.caption1)
		window.bestScore:Show()
	elseif (peggleLoot) then
		addBalls = 1;
		window.bestScoreCaption:SetFormattedText(window.bestScoreCaption.caption3, "30")
		window.bestScore:Hide()
	elseif (duel) then
		window.bestScoreCaption:SetFormattedText(window.bestScoreCaption.caption2, "4m 59s")
		window.bestScore:Hide()
	else
		window.bestScoreCaption:SetText(window.bestScoreCaption.caption1)
		window.bestScore:Show()
	end
			
	for i = 1, addBalls do
		window.ballTracker:UpdateDisplay(2);
	end
	window.ballTracker:UpdateDisplay(1);

	window.feverTracker:UpdateDisplay(1);

--	-- If we have the talent for starting with some bars active, run it now
--	for i = 1, talentData[33 + 3] do 
--		window.feverTracker:UpdateDisplay(3);
--	end
--	window.feverTracker:UpdateDisplay(2);

	window.catcher.elapsed = const.catcherLoopTime / 4;
	UpdateMove_Line(window.catcher);

	if not (challenge or duel) then

		local db = gameObjectDB;
		-- Get a list of all available pegs in play
		for j = 1, #db do 
			for i = 1, #db[j] do 
				for k = 1, #db[j][i] do 
					obj = db[j][i][k];
					tinsert(availablePegs, obj);
				end	
			end
		end

		-- Now, we redistribute the reds
		for i = 1, 25 do 

			-- If we have pegs left to pick from (blue ones), continue
			if (#availablePegs > 0) then

				-- Pick a random plug peg from the list and make it a purple one
				obj = tremove(availablePegs, math.random(1, #availablePegs));
				obj.id = PEG_RED;
				obj.required = true;
				feverPegsTotal = feverPegsTotal + 1;
				if (obj.isPeg) then
					obj.texture:SetTexCoord(0 + ((PEG_RED - 1) * 0.25), (PEG_RED * 0.25),0,0.5);
				else
					obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_RED] .. "Brick" .. const.curvedBrick[obj.radius]);
				end
			end

		end

		local lastGreen;
		local greenFound;
		local greenRadius = (thePegRadius * 9)^2;

		-- Now, we redistribute the greens
		for i = 1, 2 do 

			-- If we have pegs left to pick from (blue ones), continue
			if (#availablePegs > 0) then

				-- Pick a random blue peg from the list and make it a green one
				obj = tremove(availablePegs, random(1, #availablePegs));
				greenFound = nil;
				while (greenFound == nil) do 
					if (lastGreen) then
						if (((obj.x - lastGreen.x)^2) + ((obj.y - lastGreen.y)^2)) < greenRadius then
							if (#availablePegs > 0) then
								obj = tremove(availablePegs, random(1, #availablePegs));
							end
						else
							greenFound = true;
						end
					else
						lastGreen = obj;
						greenFound = true;
					end
				end

				obj.id = PEG_GREEN;
				if (obj.isPeg) then
					obj.texture:SetTexCoord(0 + ((PEG_GREEN - 1) * 0.25), (PEG_GREEN * 0.25),0,0.5);
				else
					obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_GREEN] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
				end
			end
		end

		-- Now, if redistribute the purples
		for i = 1, 1 do 

			-- If we have pegs left to pick from (blue ones), continue
			if (#availablePegs > 0) then

				colorBlind = "";
				if (PeggleData.settings.colorBlindMode) then
					colorBlind = "_";
				end

				-- Pick a random plug peg from the list and make it a purple one
				obj = tremove(availablePegs, random(1, #availablePegs));
				obj.id = PEG_PURPLE;
				if (obj.isPeg) then
					obj.texture:SetTexCoord(0 + ((PEG_PURPLE - 1) * 0.25), (PEG_PURPLE * 0.25),0,0.5);
				else
					obj.texture:SetTexture(const.artPath .. const.brickTex[PEG_PURPLE] .. "Brick" .. const.curvedBrick[obj.radius] .. colorBlind);
				end
			end
		end

		-- Pick a random blue peg to be a purple peg;
		ReclaimPegs();

	end

	if (peggleLoot) then
		specialCount = 0;
		specialType = SPECIAL_BLAST;
		specialName = const.locale["_SPECIAL_NAME2"];
		window.charScreen:Hide();
		window.shooter.face:SetTexture(const.artPath .. "char" .. (specialType + 1) .. "Face");
		const[const.newInfo[13]] = true;
	else
		window.charScreen:Show();
		window.shooter.face:SetTexture(const.artPath .. "char" .. (window.charScreen.focus:GetID() + 1) .. "Face");
		const[const.newInfo[13]] = nil;
		window.peggleLootTimer.remaining = -100;
	end

	-- Only let talents work outside of Peggle Loot mode
	if not const[const.newInfo[13]] then

		-- If we have the talent for starting with some bars active, run it now
		for i = 1, talentData[33 + 3] do 
			window.feverTracker:UpdateDisplay(3);
		end
	
	end
	window.feverTracker:UpdateDisplay(2, 5);

	collectgarbage();

end

local function StyleShotCalculate(styleType, x, y)

	-- Very basic tricky to prevent some people from trying to find how how
	-- to give themselves crazy points...

	local multiplier = 0;

	-- Only let talents work outside of Peggle Loot mode
	if not const[const.newInfo[13]] then
		multiplier = talentData[33 + 2];
	end

	local thousand = 1000 
	multiplier = (1 + multiplier * 0.02);

	local score;
	local style = "_ST" .. "YLE" .. "SHO" .. "T_" .. tostring(styleType);

	-- Free ball skills
	if (styleType == 1) then
		if ((specialInPlay == 1) and (#animator.hitPegStack == 1)) or (specialInPlay == 2)  then
			score = 5 * thousand;
		end

	-- Long shot
	elseif (styleType == 2) then
		score = 25 * thousand;

	-- Super long shot
	elseif (styleType == 3) then
		score = 50 * thousand;

	-- Mad skillz or Crazy Mad skills
	elseif (styleType == 4) then
		if (specialInPlay == 1) and (#animator.hitPegStack > 0) then
			freeBallCombo = freeBallCombo + 1;
			if (freeBallCombo == 5) and (freeBallComboGet == 0)  then
				freeBallComboGet = 1;
				score = 25 * thousand;
				if (specialInPlay == 1) and (#animator.hitPegStack == 1) then
					y = y + 10;
				end
			elseif (freeBallCombo == 10) and (freeBallComboGet == 1) then
				freeBallComboGet = 2;
				score = 100 * thousand;
				style = style .. "a";
				if (specialInPlay == 1) and (#animator.hitPegStack == 1) then
					y = y + 10;
				end
			end
		else
			freeBallCombo = 0;
		end

	-- Extreme slide
	elseif (styleType == 5) then
		if (slideComboCount >= 12) then
			score = 50 * thousand;
			slideComboCount = 0;
		end

	-- Orange attack
	elseif (styleType == 6) then
		if (orangeAttackCount >= 0) then
			score = 50 * thousand;
			orangeAttackCount = -30;
		end
	end

	if (score) then
		bonusScoreTalents = bonusScoreTalents + floor(score * multiplier);
		bonusScore = bonusScore + floor(score);
		animator:SpawnText(window.catcher, const.locale[style] .. NumberWithCommas(floor(score * multiplier)), 0.4, 1, 1, 0, 0, x, y);
		return true;
	end
end

local function ScoreCalculate(obj, doubleCount, extraCrit)
	
	local hitScore = 0;
	local currentMultiplier = feverMultiplier;
	local currentPegsHit = 0;
	local critChance = 0; 
	local critBonus = 1;
	local colorBlind = "";

	-- Only let talents work outside of Peggle Loot mode
	if not const[const.newInfo[13]] then
		
		critChance = (talentData[33 + 5] * 5);

		if (extraCrit) and (extraCrit > 0) then
			critChance = extraCrit;
		end
		if (specialType == SPECIAL_GUIDE) and (specialInPlay == true) and (#animator.hitPegStack < 2) then
			critChance = talentData[33 + 9] * 20;
		end

		if not doubleCount then
			if (random(1, 100) <= critChance) then
				critBonus = 1.50 + talentData[33 + 7] * 0.1;
				animator:SpawnGlow(obj, true);
			end
		end
	end

	-- Fever mode gives more points
	if (feverPegsHit >= feverPegsTotal) then
		currentMultiplier = 55 + 45;
	end

	-- Long shot checks
	if (lastPeg) and (lastPeg.id ~= PEG_BLUE) and (obj.id ~= PEG_BLUE) then
		distance = sqrt((lastPeg.x - obj.x)^2 + (lastPeg.y - obj.y)^2);
--		distance = abs(lastPeg.x - obj.x);
		if (distance >= (0.66 * const.boardWidth)) then
			StyleShotCalculate(3, obj.x, obj.y)
		elseif (distance >= (0.33 * const.boardWidth)) then
			StyleShotCalculate(2, obj.x, obj.y)
		end
		lastPeg = obj;
	end

	if (obj.id == PEG_RED) then

--		Sound(const.SOUND_PEG_HIT);

		hitScore = hitScore + PEG_RED_VALUE;

		-- Update fever meter
		if not doubleCount then
			feverPegsHit = feverPegsHit + 1;
			window.feverTracker:UpdateDisplay(3);
		end

		-- Update the style shot data
		orangeAttackCount = orangeAttackCount + 1;
		StyleShotCalculate(6, obj.x, obj.y)

		-- Find the last peg
		if (feverPegsHit == (feverPegsTotal - 1)) then
			local db = animator.animationStack;
			local obj;
			for i = 1, #db do 
				obj = db[i];
				if (obj.id == PEG_RED) and not (obj.hit) then
					animator.lastPeg = obj;
					break;
				end
			end
		end

	elseif (obj.id == PEG_PURPLE) then
		Sound(const.SOUND_POWERUP);

		-- Fever mode gives different points for purple pieces
		if (feverPegsHit >= feverPegsTotal) then
			hitScore = hitScore + PEG_RED_VALUE
		else
			hitScore = hitScore + PEG_PURPLE_VALUE
		end

		if (extraCrit) and (extraCrit ~= 0) then
			animator:SpawnText(obj, const.locale["_TALENT8_NAME"], 1, 0.5, 1, 0, 40, obj.x, obj.y, 0.35);
		else
			animator:SpawnText(obj, const.locale["_POINT_BOOST"], 1, 0.5, 1, 0, 40, obj.x, obj.y, 0.35);
		end

		-- Only let talents work outside of Peggle Loot mode
		if not const[const.newInfo[13]] then
			if (talentData[33 + 6] > 0) then
				if (random(1, 100) < (talentData[33 + 6] * 10)) then
					window.feverTracker:UpdateDisplay(3);
				end
			end
			if (talentData[33 + 11] > 0) then
				local i, reHit;
				for i = 1, #animator.hitPegStack do
					reHit = animator.hitPegStack[i];
					ScoreCalculate(reHit, true);
				end
			end
		end

	elseif (obj.id == PEG_GREEN) then
		hitScore = hitScore + PEG_GREEN_VALUE;
		if not doubleCount then
			local i, peg, doBlast, doBlastSpecial;
			local blastDist = (thePegRadius * 5);

			-- Only let talents work outside of Peggle Loot mode
			if not const[const.newInfo[13]] then
				if (random(1, 100) < (talentData[33 + 8] * 10)) then
					doBlastSpecial = true;
				end
			end

			if (specialType == SPECIAL_GUIDE) then
				Sound(const.SOUND_POWERUP_GUIDE);
				specialCount = specialCount + 3;
				animator:SpawnText(obj, specialName .. "\n" .. const.locale["_NEXT"] .. specialCount .. const.locale["_TURNS"], 0.5, 1, 0.5, 0, 40, obj.x, obj.y, 0.35);
				window.powerLabel.text:SetText(const.locale["_SPECIAL_NAME1"] .. " " .. specialCount);
				window.powerLabel:Show();
				GUIDE_HITS = 2;
				showGuide = true;
			else
				animator:SpawnText(obj, specialName, 0.5, 1, 0.5, 0, 40, obj.x, obj.y, 0.35);
				blastDist = (blastDist * 2);
				doBlast = true;
				animator:SpawnGlow(obj, nil, 2);
			end

			if (doBlast) then

				Sound(const.SOUND_POWERUP_BLAST);
				blastDist = blastDist^2;
				animator:SpawnGlow(obj, nil, 2);

				local blastBonus = 0;

				-- Only let talents work outside of Peggle Loot mode
				if not const[const.newInfo[13]] then
					blastBonus = talentData[33 + 9] * 20;
				end

				if (specialType == SPECIAL_GUIDE) then
					blastBonus = 0;
				end
				for i = 1, #animator.animationStack do 
					peg = animator.animationStack[i];
					if not peg.hit then
						-- Determine if the peg is within the blast radius
						if (((obj.x - peg.x)^2 + (obj.y - peg.y)^2) <= blastDist) then
							peg.hit = true;
							ScoreCalculate(peg, nil, blastBonus);
							if (peg.isBrick) then
								colorBlind = "";
								if (PeggleData.settings.colorBlindMode) and (peg.id > PEG_RED) then
									colorBlind = "_";
								end
								peg.texture:SetTexture(const.artPath .. const.brickTex[peg.id] .. "Brick" .. const.curvedBrick[peg.radius] .. "a" .. colorBlind);
							else
								peg.texture:SetTexCoord(0 + ((peg.id - 1) * 0.25),(peg.id * 0.25),0.5,1);
							end
						end
					end
				end
			end

			if (doBlastSpecial) then

				Sound(const.SOUND_POWERUP_BLAST);
				blastDist = (thePegRadius * 5)^2;

				local blastBonus = 0;

				-- Find the pink peg
				local pinkPeg;
				for i = 1, #animator.animationStack do 
					peg = animator.animationStack[i];
					if (peg.id == PEG_PURPLE) then
						pinkPeg = peg;
						break;
					end
				end

				-- If there was a pink peg on the board, continue
				if (pinkPeg) then
					animator:SpawnGlow(pinkPeg, nil, 1);
					for i = 1, #animator.animationStack do 
						peg = animator.animationStack[i];
						if not peg.hit then
							-- Determine if the peg is within the blast radius
							if (((pinkPeg.x - peg.x)^2 + (pinkPeg.y - peg.y)^2) <= blastDist) then
								peg.hit = true;
								ScoreCalculate(peg, nil, blastBonus);
								if (peg.isBrick) then
									colorBlind = "";
									if (PeggleData.settings.colorBlindMode) and (peg.id > PEG_RED) then
										colorBlind = "_";
									end
									peg.texture:SetTexture(const.artPath .. const.brickTex[peg.id] .. "Brick" .. const.curvedBrick[peg.radius] .. "a" .. colorBlind);
								else
									peg.texture:SetTexCoord(0 + ((peg.id - 1) * 0.25),(peg.id * 0.25),0.5,1);
								end
							end
						end
					end
				end
			end

		end
			
	else
--		Sound(const.SOUND_PEG_HIT);
		hitScore = hitScore + PEG_BLUE_VALUE;
--		if (obj.type == 4) then
--			bonusMultiplier = 2;
--		end
	end

	if not doubleCount then
		animator:SpawnGlow(obj);
		pegsHit = pegsHit + 1;
		tinsert(animator.hitPegStack, obj);
		const.stats[3] = const.stats[3] + 1;
		local seg, height;
		if (const.stats[3] == const.stats[7]) then
			seg = window.bonusBar3.coord;
			height = floor((seg[4] - seg[3]) * 512 + 0.5);
			window.bonusBar1:SetTexCoord(unpack(seg));
			window.bonusBar1:SetHeight(height);
			window.bonusBar2:SetTexCoord(unpack(seg));
			window.bonusBar2:SetHeight(height);
			window.bonusBar3:SetTexCoord(unpack(seg));
			window.bonusBar3:SetHeight(height);
			window.bonusBar4:SetTexCoord(unpack(seg));
			window.bonusBar4:SetHeight(height);
			window.bonusBar5:SetTexCoord(unpack(seg));
			window.bonusBar5:SetHeight(height);
			window.fever2:Show();
		else
			seg = window.bonusBar1.coord;
			height = floor((seg[4] - seg[3]) * 512 + 0.5);
			window.bonusBar1:SetTexCoord(unpack(seg));
			window.bonusBar1:SetHeight(height);
			window.bonusBar5:SetTexCoord(unpack(seg));
			window.bonusBar5:SetHeight(height);
			seg = window.bonusBar2.coord;
			height = floor((seg[4] - seg[3]) * 512 + 0.5);
			window.bonusBar2:SetTexCoord(unpack(seg));
			window.bonusBar2:SetHeight(height);
			window.bonusBar4:SetTexCoord(unpack(seg));
			window.bonusBar4:SetHeight(height);
			seg = window.bonusBar3.coord;
			window.bonusBar3:SetTexCoord(unpack(seg));
			window.bonusBar3:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
		end					
		currentPegsHit = #animator.hitPegStack;
		if (currentPegsHit < 19) then
			if (window.range == 1) then
				local num = -12 + currentPegsHit;
				if (num < 0) then
					Sound(const.sounds[const.SOUND_PEG_HIT] .. "_plus4b" .. tostring(num) .. ".ogg");
				else
					Sound(const.sounds[const.SOUND_PEG_HIT] .. "_plus4b+" .. tostring(num) .. ".ogg");
				end
			elseif (window.range == 2) then
				Sound(const.sounds[const.SOUND_PEG_HIT] .. "_plus_mega9.ogg");
			else
				Sound(const.sounds[const.SOUND_PEG_HIT] .. "x" .. currentPegsHit .. ".ogg");
			end
		else
			if (window.range == 1) then
				local num = -12 + currentPegsHit;
				if (num > 9) then
					num = 9;
				end
				Sound(const.sounds[const.SOUND_PEG_HIT] .. "_plus4b+" .. tostring(num) .. ".ogg");
			elseif (window.range == 2) then
				Sound(const.sounds[const.SOUND_PEG_HIT] .. "_plus_mega9.ogg");
			else
				Sound(const.sounds[const.SOUND_PEG_HIT] .. "x18.ogg");
			end
		end
	end

	currentPegsHit = #animator.hitPegStack;

	-- Calculate score gains for round total
	roundScore = roundScore + (hitScore * currentMultiplier)
	local currentScoreNoTalent = roundScore * currentPegsHit;

	hitScore = floor(hitScore * currentMultiplier * critBonus);
	roundScoreTalents = roundScoreTalents + hitScore;
	currentScore = (roundScoreTalents * currentPegsHit);

	-- Spawn floating score
	if (doubleCount) then
		animator:SpawnText(obj, hitScore, nil, nil, nil, nil, nil, obj.x + 3, obj.y + 3, 0.1, (critBonus ~= 1));
	else
		animator:SpawnText(obj, hitScore, nil, nil, nil, nil, nil, nil, nil, nil, (critBonus ~= 1));
	end
			
	-- Update "extra ball" gauge
	window.ballTracker:UpdateDisplay(4, currentScoreNoTalent);
	
end

local function Tab_OnMouseDown(self, button)
	local x1, x2, y1, y2 = unpack(self.artCoords);
	if (self.horizontal) then
		x1 = x1 + (self:GetWidth() / 512) * 2;
		x2 = x2 + (self:GetWidth() / 512) * 2;
	else
		y1 = y1 + 0.25 * 2;
		y2 = y2 + 0.25 * 2;
	end
	self.down = true;
	self.tex:SetTexCoord(x1, x2, y1, y2);
end

local function Tab_OnMouseUp(self, button)
	
	local x1, x2, y1, y2 = unpack(self.artCoords);

	if (self.hover == true) then
		
		-- Hide all catagories
		local obj = window.catagoryScreen;
		local i;
		for i = 1, #obj.frames do 
			obj.frames[i]:Hide();			
		end
		window.about:Hide();
		window.credits:Hide();

		-- Show current catagory
		self.contentFrame:Show();

		-- Update our focused tab
		if (obj.lastFocus) and (obj.lastFocus ~= self) then
			obj.lastFocus.focus = nil;
			Tab_OnMouseUp(obj.lastFocus);
		end
		obj.lastFocus = self;
		self.focus = true;
		
		if (self.horizontal) then
			x1 = x1 + (self:GetWidth() / 512);
			x2 = x2 + (self:GetWidth() / 512);
		else
			y1 = y1 + 0.25;
			y2 = y2 + 0.25;
		end
	end
	self.down = nil;
	self.tex:SetTexCoord(x1, x2, y1, y2);
end

local function Tab_OnEnter(self)
	local x1, x2, y1, y2 = unpack(self.artCoords);
	if (self.down) then
		if (self.horizontal) then
			x1 = x1 + (self:GetWidth() / 512) * 2;
			x2 = x2 + (self:GetWidth() / 512) * 2;
		else
			y1 = y1 + 0.25 * 2;
			y2 = y2 + 0.25 * 2;
		end
	else
		if (self.horizontal) then
			x1 = x1 + (self:GetWidth() / 512);
			x2 = x2 + (self:GetWidth() / 512);
		else
			y1 = y1 + 0.25;
			y2 = y2 + 0.25;
		end
	end
	self.tex:SetTexCoord(x1, x2, y1, y2);
	self.hover = true;
end

local function Tab_OnLeave(self)
	local x1, x2, y1, y2 = unpack(self.artCoords);
	if self.focus then
		if (self.horizontal) then
			x1 = x1 + (self:GetWidth() / 512);
			x2 = x2 + (self:GetWidth() / 512);
		else
			y1 = y1 + 0.25;
			y2 = y2 + 0.25;
		end
	end
	self.tex:SetTexCoord(x1, x2, y1, y2);
	self.hover = nil;
end

const.sparkleFunc = function (self, elapsed)
	local i;
	for i = 1, #self.timer do 
		self.timer[i] = self.timer[i] + elapsed;
		if (self.timer[i] > self.speed[i] * 4) then
			self.timer[i] = 0;
		end
	end
	
	local distanceX, distanceY = self:GetWidth(), self:GetHeight();
		
	local timer, speed, basePositionX, basePostionY;
	local parent = self;
	for i = 1, 4 do
		timer = self.timer[i];
		speed = self.speed[i];
		if ( timer <= speed ) then
			basePositionX = timer/speed*distanceX;
			basePositionY = timer/speed*distanceY;
			self.sparkles[0+i]:SetPoint("CENTER", parent, "TOPLEFT", basePositionX, 0);
			self.sparkles[4+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePositionX, 0);
			self.sparkles[8+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePositionY);
			self.sparkles[12+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePositionY);
		elseif ( timer <= speed*2 ) then
			basePositionX = (timer-speed)/speed*distanceX;
			basePositionY = (timer-speed)/speed*distanceY;
			self.sparkles[0+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePositionY);
			self.sparkles[4+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePositionY);
			self.sparkles[8+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePositionX, 0);
			self.sparkles[12+i]:SetPoint("CENTER", parent, "TOPLEFT", basePositionX, 0);	
		elseif ( timer <= speed*3 ) then
			basePositionX = (timer-speed*2)/speed*distanceX;
			basePositionY = (timer-speed*2)/speed*distanceY;
			self.sparkles[0+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePositionX, 0);
			self.sparkles[4+i]:SetPoint("CENTER", parent, "TOPLEFT", basePositionX, 0);
			self.sparkles[8+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePositionY);
			self.sparkles[12+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePositionY);	
		else
			basePositionX = (timer-speed*3)/speed*distanceX;
			basePositionY = (timer-speed*3)/speed*distanceY;
			self.sparkles[0+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePositionY);
			self.sparkles[4+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePositionY);
			self.sparkles[8+i]:SetPoint("CENTER", parent, "TOPLEFT", basePositionX, 0);
			self.sparkles[12+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePositionX, 0);
		end
	end	
end

local function CreateTab(x, y, parent, frame, tabArtCoords, horizontal, hasSparkles)

	local seg = const.artCut[tabArtCoords];
	local tab = CreateFrame("Frame", "", parent);
	tab:SetPoint("Topleft", x, 0);
	tab:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tab:SetHeight(floor((seg[4] - seg[3]) * 256 + 0.5));

	tex = tab:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "tabs");
	tex:SetAllPoints(tab);
	tex:SetTexCoord(unpack(seg));
	tab.tex = tex;
	
	tab.artCoords = seg;
	tab.contentFrame = frame
	tab.horizontal = horizontal;

	tab:EnableMouse(true);
	tab:SetScript("OnMouseDown", Tab_OnMouseDown);
	tab:SetScript("OnMouseUp", Tab_OnMouseUp);
	tab:SetScript("OnEnter", Tab_OnEnter);
	tab:SetScript("OnLeave", Tab_OnLeave);

	if (hasSparkles) then
		window.sparkCount = (window.sparkCount or (0)) + 1 
		local sparkFrame = CreateFrame("Frame", "PeggleSparks" .. window.sparkCount, tab, "AutoCastShineTemplate")
		sparkFrame:ClearAllPoints();
		sparkFrame:SetPoint("Topleft", 6, -6);
		sparkFrame:SetWidth(tab:GetWidth() - 12);
		sparkFrame:SetHeight(tab:GetHeight() - 12);
		sparkFrame:SetScript("OnUpdate", const.sparkleFunc);
		tab.sparks = sparkFrame;
		tab.sparks:Hide();

		sparkFrame.sparkles = {};
		if (hasSparkles == 1) then
			sparkFrame.speed = {2, 2, 2, 2};
			sparkFrame.timer = {0, 0.5, 1, 1.5};
		elseif (hasSparkles == 2) then
			sparkFrame.speed = {2, 4, 6, 8};
			sparkFrame.timer = {0, 0, 0, 0};
		else
			sparkFrame.speed = {1, 2, 3, 4};
			sparkFrame.timer = {0, 0, 0, 0};
		end
		local name = sparkFrame:GetName();
		local i;
		for i = 1, 16 do
			tinsert(sparkFrame.sparkles, getglobal(name .. i));
			sparkFrame.sparkles[i]:Show();
			sparkFrame.sparkles[i]:SetVertexColor(1, 1, 0);
		end
	end

	return tab, (x + tab:GetWidth());
	
end

local function CreateTextbox(x, y, width, objectName, parent, numericOnly, maxLength, updateFunc, tooltipText)

	-- Create message text box
	local obj = CreateFrame("EditBox", "PeggleTextBox_" .. objectName, parent, "InputBoxTemplate");
	obj:SetPoint("Topleft", x+6, -(y-4))
	obj:SetWidth(width);
	obj:SetHeight(32);
	obj:SetAutoFocus(false);
	obj:SetNumeric(numericOnly);
	obj:SetMaxLetters(maxLength);
	obj:SetHitRectInsets(0, 0, 8, 8);

	obj:Show();

--	obj:SetScript("OnEditFocusGained", TextBox_FocusGained);

	if (updateFunc) then
--		obj.key = objectName;
		obj:SetScript("OnEnterPressed", updateFunc);
	end

	if (tooltipText) then
		obj.tooltipText = tooltipText
		obj.oldOnEnter = obj:GetScript("OnEnter");
		obj.oldOnLeave = obj:GetScript("OnLeave");
		obj:SetScript("OnEnter", Tooltip_Show);
		obj:SetScript("OnLeave", Tooltip_Hide);
	end

	-- return the object and new y location for next object to use
	return obj, y + 24;
	
end

local function CreateCheckbox(xLoc, yLoc, objectText, objectSetting, enabledValue, objectParent, settingUpdateFunction, r, g, b, tooltipText, peggleFont)

	-- Set our local
	local obj = CreateFrame("CheckButton", "PeggleCheckbox_" .. objectSetting, objectParent, "OptionsCheckButtonTemplate");

	obj:SetWidth(21);
	obj:SetHeight(21);
	obj:SetPoint("Topleft", xLoc, -yLoc);

	local text = getglobal(obj:GetName() .. "Text");
	if (peggleFont) then
		text:SetFont(const.artPath .. "OVERLOAD.ttf", 10);
		obj:SetWidth(17);
		obj:SetHeight(17);
	else
		text:SetFont(STANDARD_TEXT_FONT, 14);
	end
	text:SetJustifyV("Top");
	text:SetJustifyH("Left");
	text:ClearAllPoints();
	text:SetPoint("Topleft", obj, "TopRight", 0, -4);
	text:SetText(objectText);
	text:SetTextColor((r or 1), (g or 1), (b or 1));

	if (settingUpdateFunction) then
		obj.key = objectSetting;
		obj:SetScript("OnClick", settingUpdateFunction);
	end

	if (PeggleData.settings[objectSetting] == enabledValue) then
		obj:SetChecked(true);
	end

	if (tooltipText) then
		obj.tooltipText = tooltipText
		obj.oldOnEnter = obj:GetScript("OnEnter");
		obj.oldOnLeave = obj:GetScript("OnLeave");
		obj:SetScript("OnEnter", Tooltip_Show);
		obj:SetScript("OnLeave", Tooltip_Hide);
	end

	-- return the object and new y location for next object to use
	return obj, yLoc + 20;

end

function Peggle:CreateSlider(xLoc, yLoc, width, objectText, objectSetting, objectParent, minValue, maxValue, valueStep, usePercent, updateFunction, size, r, g, b, peggleFont)

	local tempObject = CreateFrame("Slider", "PeggleSlider" .. objectSetting, objectParent, "OptionsSliderTemplate");
	tempObject:SetWidth(width);

	getglobal(tempObject:GetName() .. "Thumb"):Show();
	if (peggleFont) then
		getglobal(tempObject:GetName() .. "Text"):SetFont(const.artPath .. "OVERLOAD.ttf", size or 14);
	else
		getglobal(tempObject:GetName() .. "Text"):SetFont(STANDARD_TEXT_FONT, size or 14);
	end
	getglobal(tempObject:GetName() .. "Text"):SetShadowOffset(1,-1);
	getglobal(tempObject:GetName() .. "Text"):SetText(objectText);
	getglobal(tempObject:GetName() .. "Text"):SetVertexColor(r or 1, g or 1, b or 0);
	getglobal(tempObject:GetName() .. "Low"):SetText(""); --minValue);
	getglobal(tempObject:GetName() .. "Low"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	getglobal(tempObject:GetName() .. "High"):SetText(""); --maxValue);
	getglobal(tempObject:GetName() .. "High"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	tempObject.valueCaption = Peggle:CreateCaption(0, 0, "", tempObject, size or 14, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	tempObject.valueCaption:ClearAllPoints();
	tempObject.valueCaption:SetPoint("Topleft", tempObject, "Topright");

	tempObject:SetHitRectInsets(0, 0, 0, 0);

	tempObject:SetMinMaxValues(minValue, maxValue);
	tempObject:SetValueStep(valueStep);

	if (PeggleData.settings[objectSetting]) then
		if (usePercent) then
			tempObject.valueCaption:SetFormattedText(": %d%%", (PeggleData.settings[objectSetting] * 100));
		else
			tempObject.valueCaption:SetFormattedText(": %d", PeggleData.settings[objectSetting]);
		end
		tempObject:SetValue(PeggleData.settings[objectSetting]);
	else
		tempObject:SetValue(minValue);
		if (usePercent) then
			tempObject.valueCaption:SetFormattedText(": %d%%", (minValue * 100));
		else
			tempObject.valueCaption:SetFormattedText(": %d", minValue);
		end
	end

	tempObject:SetPoint("Topleft", xLoc, yLoc);
	tempObject:SetScript("OnValueChanged", Peggle.CreateSlider_OnValueChanged);
	tempObject.updateFunc = updateFunction;
	tempObject.objectSetting = objectSetting;
	tempObject.usePercent = usePercent;
	
	-- return the object
	return tempObject

end

function Peggle.CreateSlider_OnValueChanged(self)

	if (PeggleData.settings[self.objectSetting]) then
		PeggleData.settings[self.objectSetting] = self:GetValue();
	end
	
	if (self.usePercent) then
		self.valueCaption:SetFormattedText(": %d%%", (self:GetValue() * 100));
	else
		self.valueCaption:SetFormattedText(": %d", self:GetValue());
	end

	if (self.updateFunc) then
		self:updateFunc();
	end
	
end

-- /***********************************************
--   CreateCaption
--	 Creates a text caption at a specified location
--  *********************/
function Peggle:CreateCaption(x, y, text, parent, size, r, g, b, point, noBorder, borderType)

	local obj = parent:CreateFontString(nil, "Overlay");
	if (point == true) then
		obj:SetFont(const.artPath .. "OVERLOAD.ttf", (size or 10), (borderType or "Outline")); --Contb___
	elseif (point == 1) then
		obj:SetFont(const.artPath .. "OVERLOAD.ttf", (size or 10), (borderType or "Outline"));
	else
		if (noBorder) then
			obj:SetFont(STANDARD_TEXT_FONT, (size or 10));
		else
			obj:SetFont(STANDARD_TEXT_FONT, (size or 10), (borderType or "Outline"));
		end
	end
	obj:SetTextColor((r or 1), (g or 1), (b or 1));
	obj:SetPoint("Topleft", x, -y);
	obj:SetText(text);
	obj:Show();

	return obj;

end

function Peggle:SkinDropdown(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList)

	local backdrop = getglobal("DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "MenuBackdrop");
	if not Peggle.dropdownSkin then
		Peggle.dropdownSkin = backdrop:GetBackdrop()
		Peggle.dropdownSkinPeggle = backdrop:GetBackdrop();
		Peggle.dropdownSkinPeggle.bgFile = const.artPath .. "windowBackground";
		Peggle.dropdownSkinPeggle.tileSize = 64;
		Peggle.dropdownSkinPeggle.insets.right = 3;
		Peggle.dropdownSkinPeggle.insets.left = 3;
		Peggle.dropdownSkinPeggle.insets.top = 3;
		Peggle.dropdownSkinPeggle.insets.bottom = 3;

		Peggle.dropdownSkinColor = { backdrop:GetBackdropColor() };
	end

	local menuObj;
	if (type(UIDROPDOWNMENU_OPEN_MENU) == "table") then
		menuObj = UIDROPDOWNMENU_OPEN_MENU
	elseif (type(UIDROPDOWNMENU_OPEN_MENU) == "string") then
		menuObj = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	else
		menuObj = nil;
	end

	if (menuObj) then
		if (menuObj.peggleMenu) then
			backdrop:SetBackdrop(Peggle.dropdownSkinPeggle);
			backdrop:SetBackdropColor(0.1,0.1,0.1,1.0);
			backdrop:SetFrameLevel(0);
		else
			backdrop:SetBackdrop(Peggle.dropdownSkin);
			backdrop:SetBackdropColor(unpack(Peggle.dropdownSkinColor));
		end
	end

end

local function Dropdown_Item_OnClick(self, isName)

	local value

	-- Channel list
	if (isName == 1) then
		local menu = UIDROPDOWNMENU_OPEN_MENU;
		UIDropDownMenu_SetText(menu, self:GetText(), menu);
--		UIDropDownMenu_SetSelectedName(menu, self:GetText());
		UIDropDownMenu_SetSelectedValue(menu, self.value); --:GetText());
		PeggleData.settings.defaultPublish = self.value;

	-- Name list
	elseif isName then

		local frame = window.catagoryScreen.frames[2];
		frame.name2:SetText(PeggleProfile.lastDuels[self.value]);

	-- Level list
	else
		if not self.forced then
			local menu = UIDROPDOWNMENU_OPEN_MENU;
			UIDropDownMenu_SetText(menu, self:GetText(), menu);
			UIDropDownMenu_SetSelectedName(menu, self:GetText());
			menu.selectedValue = self.value;
			if (menu.updateFunc) then
				menu.updateFunc:SetTexture(const.artPath .. "BG" .. self.value .. "_thumb");
			end
			value = self.value;
		else
			self.forced = nil;
			value = self.selectedValue or (1);
			local newText = string.format(const.locale["_LEVEL_INFO"], value, const.locale["_LEVEL_NAME" .. value]);
			UIDropDownMenu_SetText(self, newText, self);
	--		UIDropDownMenu_SetSelectedName(self, newText);
			self.selectedValue = value;
			if (self.updateFunc) then
				self.updateFunc:SetTexture(const.artPath .. "BG" .. value .. "_thumb");
			end
		end

		local frame = window.catagoryScreen.frames[1];
		frame:UpdateDisplay(value);

	end

end

local function Dropdown_Initialize(self)

	if (UIDROPDOWNMENU_MENU_LEVEL == 1) then

		local flag
		local i;
		local info = const.dropInfo;

		-- Name dropdown list
		if (self.names) then

			getglobal("DropDownList1").maxWidth = 240;

			table.wipe(info);
			info.text = const.locale["_DUEL_HISTORY"];
			info.isTitle = true;
			info.value = 0;
			UIDropDownMenu_AddButton(info);

			if (PeggleProfile.lastDuels) and (PeggleProfile.lastDuels[1]) then
				for i = 1, #PeggleProfile.lastDuels do 
					table.wipe(info);
					info.text = PeggleProfile.lastDuels[i];
					info.value = i;
					info.arg1 = true;
					info.func = Dropdown_Item_OnClick;
					UIDropDownMenu_AddButton(info);
				end
			else
				table.wipe(info);
				info.text = const.locale["_DUEL_NO_HISTORY"];
				info.notClickable = true;
				info.value = 0;
				UIDropDownMenu_AddButton(info);
			end			

		-- Publish channel list
		elseif (self.publish) then

--			getglobal("DropDownList1").maxWidth = 240;

			table.wipe(info);
			local defaultChannel = const.channels[1];

			-- Add default channels (guild, party, raid)
			for i = 1, 3 do 
				table.wipe(info);
				info.text = const.locale["_PUBLISH_" .. i];
				info.value = const.channels[i];
				if (PeggleData.settings.defaultPublish == info.value) then
					defaultChannel = info.value;
				end
				info.arg1 = 1;
				info.func = Dropdown_Item_OnClick;
				UIDropDownMenu_AddButton(info);
			end

			-- Add custom channels
			local lowerPublish = string.lower(PeggleData.settings.defaultPublish);
			local bragScreen = self:GetParent();
			bragScreen:refreshChannels(EnumerateServerChannels())
			for i = 1, #bragScreen.channelNames do 
				table.wipe(info);
				info.text = bragScreen.channelNames[i];
				if (lowerPublish == string.lower(info.text)) then
					defaultChannel = info.text;
				end
				info.value = info.text;
				info.arg1 = 1;
				info.func = Dropdown_Item_OnClick;
				UIDropDownMenu_AddButton(info);
			end

			PeggleData.settings.defaultPublish = defaultChannel;
			
		-- Level dropdown list
		else

			getglobal("DropDownList1").maxWidth = 280;

			for i = 1, 12 do

				-- Wipe our information table
				table.wipe(info);
				info.text = string.format(const.locale["_LEVEL_INFO"], i, const.locale["_LEVEL_NAME" .. i]);
				info.value = i;
				info.fontObject = window.fontObj;
				info.icon = const.artPath .. "bannerMenu";

				-- Update flags
				flag = scoreData[i + 12];
				if (flag == 3) then
					info.tCoordLeft = 0;
					info.tCoordRight = 0.5;
					info.tCoordTop = 0.5;
					info.tCoordBottom = 1;
				elseif (flag == 2) then
					info.tCoordLeft = 0.5;
					info.tCoordRight = 1;
					info.tCoordTop = 0;
					info.tCoordBottom = 0.5;
				else
					info.tCoordLeft = 0;
					info.tCoordRight = 0.5;
					info.tCoordTop = 0;
					info.tCoordBottom = 0.5;
				end

				info.checked = nil;
				info.func = Dropdown_Item_OnClick
								
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

local function Dropdown_OnShow(self)

	local temp = self.selectedValue;
--	if not self.names then
--		self.displayMode = "MENU";
--	end

	UIDropDownMenu_SetAnchor(self, 0, 0, "Top", self, "Bottom");
	UIDropDownMenu_Initialize(self, Dropdown_Initialize);

	if (self.publish) then
--		UIDropDownMenu_SetSelectedName(self, const.locale["_PUBLISH_" .. PeggleData.settings.defaultPublish]);
		UIDropDownMenu_SetSelectedValue(self, PeggleData.settings.defaultPublish)
		temp = PeggleData.settings.defaultPublish;
	else	
		UIDropDownMenu_SetSelectedName(self, string.format(const.locale["_LEVEL_INFO"], self.selectedValue, const.locale["_LEVEL_NAME" .. self.selectedValue]));
	end
	self.selectedValue = temp;

	UIDropDownMenu_SetWidth(self, self.menuWidth);


end

local function CreateDropdown(xLoc, yLoc, width, objectName, objectText, listName, objectParent, updateFunction, extraFeature)

	local obj = CreateFrame("Frame", "PeggleDropdown_" .. objectName, objectParent, "UIDropDownMenuTemplate");

	-- Make sure the left and right side don't mess with buttons around it
	obj:SetHitRectInsets(10, 10, 0, 0);

	if (objectText) then
		obj.text = Peggle:CreateCaption(xLoc, yLoc, objectText, objectParent, 14, 1, 1, 0, nil, nil);
		obj.text:SetParent(obj);
		obj.text:ClearAllPoints();
		obj.text:SetPoint("Bottom", obj, "Top", 0, 4);
		yLoc = yLoc + 16;
	end

--	obj.listName = listName;
	obj.updateFunc = updateFunction;
	obj.menuWidth = width;
	obj.selectedValue = 1;
	obj.peggleMenu = true;
	obj.displayMode = "MENU";

	if (objectText) then
		getglobal(obj:GetName() .. "Text"):SetFont(obj.text:GetFont());
		getglobal(obj:GetName() .. "Text"):SetVertexColor(1, 1, 1);
	else
		getglobal(obj:GetName() .. "Text"):SetFontObject(window.fontObj);
		getglobal(obj:GetName() .. "Text"):SetVertexColor(1, 0.82, 0);
	end
	getglobal(obj:GetName() .. "Text"):SetJustifyH("CENTER");

	obj:SetPoint("Topleft", xLoc-16, -yLoc);
	obj:SetScript("OnShow", Dropdown_OnShow);

	-- return the object and new y location for next object to use
	return obj, yLoc + 30;

end

local function Button_OnMouseDown(self, button)
	self.down = true;
	self.highlight:SetAlpha(0.2);
end

local function Button_OnMouseUp(self, button)
	self.down = nil;
	if (self.hover == true) then
		self.highlight:SetAlpha(0.1);
--		if (self.clickFunc) then
--			self.clickFunc(self, button);
--		end
	end
end

local function Button_OnEnter(self)
	if (self.down) then
		self.highlight:SetAlpha(0.2);
	else
		self.highlight:SetAlpha(0.1);
	end
	self.hover = true;
end

local function Button_OnLeave(self)
	self.highlight:SetAlpha(0);
	self.hover = nil;
end

local function CreateButton(x, y, height, texCoordName, rotated, objectName, parent, clickFunc, tooltipText, otherImage)

	local obj = CreateFrame("Button", "PeggleButton_" .. objectName, parent);

	local db = const.artCut[texCoordName];

--	obj:SetBackdrop(const.GetBackdrop());
--	obj:SetBackdropColor(0,0,0,0);
	obj:SetPoint("TopLeft", x, -y);
	obj:EnableMouse(true);
	obj:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp", "Button4Up", "Button5Up");

	local maxHeight = 256;
	if (otherImage) then
		maxHeight = 512;
	end

	if (rotated) then
		obj:SetWidth(floor((db[4] - db[3]) * maxHeight + 0.5));
		obj:SetHeight(floor((db[2] - db[1]) * 256 + 0.5));
	else
		obj:SetWidth(floor((db[2] - db[1]) * 256 + 0.5));
		obj:SetHeight(floor((db[4] - db[3]) * maxHeight + 0.5));
	end
	
	local scale = height / obj:GetHeight();
	obj:SetWidth(scale * obj:GetWidth());
	obj:SetHeight(scale * obj:GetHeight());

	local tex = obj:CreateTexture(nil, "Background");
	tex:SetAllPoints(obj);
	if (otherImage) then
		tex:SetTexture(const.artPath .. "board2");
	else
		tex:SetTexture(const.artPath .. "buttons");
	end
	tex:Show();
	obj.background = tex;

	if (rotated) then
		tex:SetTexCoord(db[2], db[3], db[1], db[3], db[2], db[4], db[1], db[4]);
	else
		tex:SetTexCoord(unpack(db));
	end

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetPoint("Center");
	tex:SetWidth(obj:GetWidth());
	tex:SetHeight(obj:GetHeight());
	tex:SetTexture(const.artPath .. "buttonHighlight");
	tex:SetBlendMode("ADD");
	tex:SetTexCoord(0,93/128,0,1);
	tex:SetAlpha(0);
	obj.highlight = tex;

	obj:SetScript("OnMouseDown", Button_OnMouseDown);
	obj:SetScript("OnMouseUp", Button_OnMouseUp);
	obj:SetScript("OnClick", clickFunc);
	obj:SetScript("OnEnter", Button_OnEnter);
	obj:SetScript("OnLeave", Button_OnLeave);

--[[
	if (tooltipText) then
		obj.tooltipText = tooltipText
		obj.oldOnEnter = obj:GetScript("OnEnter");
		obj.oldOnLeave = obj:GetScript("OnLeave");
		obj:SetScript("OnEnter", Tooltip_Show);
		obj:SetScript("OnLeave", Tooltip_Hide);
	end
--]]

	obj.clickFunc = clickFunc;

	-- return the object and new y location for next object to use
	return obj;

end

-- /***********************************************
--   Animator_Add
--	 Adds an object to the animation queue
--  *********************/
local function Animator_Add(self, obj)
	if not obj.animated then
		if (obj.isBall) then
			tinsert(self.activeBallStack, obj);
		else
			tinsert(self.animationStack, obj);
		end
		obj.animated = true;
	end
end

-- /***********************************************
--   Animator_CreateImage
--	 Creates an image frame with the specified parameters
--  *********************/
local function Animator_CreateImage(self, x, y, width, height, parent, overlayOnly)

	local obj = (parent or window):CreateTexture(nil, "ARTWORK")
--	local obj = CreateFrame("Frame", "", parent);
	obj:SetPoint("Topleft", x, -y);
	obj:SetWidth(width);
	obj:SetHeight(height);
	obj:Show();

	if (overlayOnly) then
--		obj.texture = obj:CreateTexture(nil, "OVERLAY");
		obj.texture = obj;
		obj:SetDrawLayer("Overlay")
	else
--		obj.texture = obj:CreateTexture(nil, "ART");
		obj.texture = obj;
	end
--	obj.texture:SetWidth(width);
--	obj.texture:SetHeight(height);
--	obj.texture:SetPoint("Center");
--	obj.texture:Show();

	obj.x = x;
	obj.y = y;

	return obj;
	
end

-- /***********************************************
--   CreateCatcher
--	 Creates the ball catcher
--  *********************/
local function CreateCatcher()

	local seg = const.artCut["catcherGlow"];

	local artSeg = gameBoard.foreground:CreateTexture(nil, "Artwork");
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetAlpha(0);
	artSeg:SetVertexColor(1,1,0.5);
	window.catcherGlow = artSeg;

--	artSeg = gameBoard:CreateTexture(nil, "Background");
	artSeg = gameBoard.foreground:CreateTexture(nil, "Background");
	artSeg:SetWidth(const.catcherWidth);
	artSeg:SetHeight(const.catcherHeight);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(const.artCut["catcherBack"]));
	window.catcherBack = artSeg;

	artSeg = window.artBorder:CreateTexture(nil, "Overlay");
	artSeg:SetWidth(const.catcherWidth);
	artSeg:SetHeight(const.catcherHeight); -- - 5);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(const.artCut["catcher"]));
	window.catcher = artSeg;

	window.catcherGlow:SetPoint("Bottom", artSeg, "Bottom", 0, 10);

	window.catcher.elapsed = 1; --const.catcherLoopTime / 2;
	window.catcher.isCatcher = true;
	window.catcher.startX = 60;
	window.catcher.startY = 9;
	window.catcher.value1 = const.boardWidth - 60;
	window.catcher.value2 = 9;
	window.catcher.reverser = true;
--	window.catcher.endX = const.boardWidth - 60;
--	window.catcher.endY = 9;
	window.catcher.rotation = 135 + 180;
	window.catcher.loopTime = const.catcherLoopTime;

	window.catcher.Update = function (self, elapsed)
		self.elapsed = self.elapsed + elapsed;
		if (self.elapsed > self.loopTime) then
			self.elapsed = mod(self.elapsed, self.loopTime);
		end
		UpdateMove_Line(self);
		self:SetPoint("Center", gameBoard, "Bottomleft", self.x, self.y);
		window.catcherBack:SetPoint("Center", gameBoard, "Bottomleft", self.x, self.y);

		if (self.freeGlowElapsed) then
			self.freeGlowElapsed = self.freeGlowElapsed + elapsed;
			if (self.freeGlowElapsed > 1) then
				self.freeGlowElapsed = nil;
				window.catcherGlow:SetAlpha(0);
--				if (not window.feverTracker.barFlashUpdate) then
					window.ballTracker:UpdateDisplay(1);
--				end
			else
				window.catcherGlow:SetAlpha(1 - self.freeGlowElapsed);
			end
		end
	end
	
end

-- /***********************************************
--   CreateFeverRay
--	 Creates the ball catcher
--  *********************/
local function CreateFeverRay()

	local seg = const.artCut["feverRay"];

	local artSeg = gameBoard.foreground:CreateTexture(nil, "Artwork");
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetAlpha(0);
	artSeg:SetVertexColor(1,1,0.5);
	window.catcherGlow = artSeg;

--	artSeg = gameBoard:CreateTexture(nil, "Background");
	artSeg = gameBoard.foreground:CreateTexture(nil, "Background");
	artSeg:SetWidth(const.catcherWidth);
	artSeg:SetHeight(const.catcherHeight);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(const.artCut["catcherBack"]));
	window.catcherBack = artSeg;

	artSeg = window.artBorder:CreateTexture(nil, "Overlay");
	artSeg:SetWidth(const.catcherWidth);
	artSeg:SetHeight(const.catcherHeight); -- - 5);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(const.artCut["catcher"]));
	window.catcher = artSeg;

	window.catcherGlow:SetPoint("Bottom", artSeg, "Bottom", 0, 10);

	window.catcher.elapsed = 1; --const.catcherLoopTime / 2;
	window.catcher.isCatcher = true;
	window.catcher.startX = 60;
	window.catcher.startY = 9;
	window.catcher.value1 = const.boardWidth - 60;
	window.catcher.value2 = 9;
	window.catcher.reverser = true;
--	window.catcher.endX = const.boardWidth - 60;
--	window.catcher.endY = 9;
	window.catcher.rotation = 135 + 180;
	window.catcher.loopTime = const.catcherLoopTime;

	window.catcher.Update = function (self, elapsed)
		self.elapsed = self.elapsed + elapsed;
		if (self.elapsed > self.loopTime) then
			self.elapsed = mod(self.elapsed, self.loopTime);
		end
		UpdateMove_Line(self);
		self:SetPoint("Center", gameBoard, "Bottomleft", self.x, self.y);
		window.catcherBack:SetPoint("Center", gameBoard, "Bottomleft", self.x, self.y);

		if (self.freeGlowElapsed) then
			self.freeGlowElapsed = self.freeGlowElapsed + elapsed;
			if (self.freeGlowElapsed > 1) then
				self.freeGlowElapsed = nil;
				window.catcherGlow:SetAlpha(0);
--				if (not window.feverTracker.barFlashUpdate) then
					window.ballTracker:UpdateDisplay(1);
--				end
			else
				window.catcherGlow:SetAlpha(1 - self.freeGlowElapsed);
			end
		end
	end
	
end

-- /***********************************************
--   Animator_SpawnBall
--	 Spawns a ball with a starting center location (x,y), desired
--   angle to travel, and magnitude of force applied to ball
--  *********************/
local function Animator_SpawnBall(self, x, y, angle, force)

	-- First, check to see if we have a ball to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.ballQueue[1];
	if obj then
		tremove(self.ballQueue, 1);
	else
		obj = self:CreateImage(0, 0, const.ballWidth, const.ballHeight, gameBoard.foreground);

		obj.isBall = true;
		obj.texture:SetTexture(const.artPath .. "ball");
		obj.texture:SetDrawLayer("Overlay")

		local i, trail;
		local r = 1
		local g = 0
		local b = 0;
		local rStep = -0.1;
		local gStep = 0.1;
		local bStep = 0;

		for i = 1, 30 do 
			trail = self:CreateImage(0, 0, const.ballWidth, const.ballHeight, gameBoard.foreground);
			trail.texture:SetTexture(const.artPath .. "ballTrail");
			trail.texture:SetVertexColor(r, g, b);
			trail.x = -100;
			trail.y = -100;
			r = r + rStep;
			g = g + gStep;
			b = b + bStep;
			if (i == 10) then
				rStep = 0;
				gStep = 0;
				bStep = 0.1;
			elseif (i == 20) then
				rStep = 0.1;
				gStep = -0.1;
				bStep = 0;
			end
			trail:SetAlpha(min((35 - i) / 30, 1));
			trail:Hide();
			obj["trail" .. i] = trail;
		end

	end

	-- Set the location data
	obj.x = x;
	obj.y = y;
	obj:ClearAllPoints();
	obj:SetPoint("Center", gameBoard, "Bottomleft", obj.x, obj.y);

	obj:SetAlpha(1)
	obj:Show();

	local j;
	for j = 1, 30 do 
		obj["trail" .. j].x = -1000;
		obj["trail" .. j].y = -1000;
		obj["trail" .. j]:Hide();
	end

	-- Calculate x and y velocities based upon angle and force
	obj.xVel = cos(rad(angle)) * force;
	obj.yVel = sin(rad(angle)) * force;

	self:Add(obj);

end

local function Animator_SetupObject(self, obj, x, y, pegType, angle, radius, moveType, elapsed, loopTime, endX, endY, value3, value4)

	-- Set the location data
	obj.x = x;
	obj.y = y;

	-- Set the velocities of this object
	obj.xVel = 0;
	obj.yVel = 0;

	-- Save it's circle radius (for movement data) and current rotation
	obj.radius = radius or 0;
	obj.rotation = mod((angle or 0) + 135, 360);
	obj.moveType = moveType or 0;

	-- Set the type of peg/brick this is (normal, goal, score, special)
	obj.id = pegType;

	-- Rotate the object if it's a brick
	if (obj.isBrick) then
		self:RotateTexture(obj.texture, obj.rotation, 0.5, 0.5)
	end

	-- Setup the animation data if we need it
	if (obj.moveType > 0) then
		obj.startX = x;
		obj.startY = y;
		obj.value1 = endX;
		obj.value2 = endY;
		obj.value3 = value3;
		obj.value4 = value4;
--		obj.endX = endX;
--		obj.endY = endY;
		if (obj.isPeg) then
--			obj.moveRadius = obj.radius;
		else
--			obj.moveRadius = obj.radius + (20-3)/2;
		end
		obj.elapsed = elapsed or 0;
		obj.loopTime = loopTime or (0.01);
	else
		obj.startX = nil;
		obj.startY = nil;
		obj.value1 = nil;
		obj.value2 = nil;
		obj.value3 = nil;
		obj.value4 = nil;
--		obj.endX = nil;
--		obj.endY = nil;
--		obj.moveRadius = nil;
		obj.elapsed = nil;
		obj.loopTime = nil;
	end

	-- Refresh it's hit status
	obj.hit = nil;
	obj.required = nil;
	obj.hitCount = 0;

	if (pegType == PEG_RED) then
		obj.required = true;
	end

	-- Add it to the animated object stack
	self:Add(obj);

	-- Set the position
	obj:ClearAllPoints();
	obj:SetPoint("Center", gameBoard, "Bottomleft", obj.x, obj.y);
	obj:SetAlpha(1)
	obj:Show();
	
end

-- /***********************************************
--   Animator_SpawnPeg
--	 Spawns a peg with a starting center location (x,y), desired
--   angle to move (for moving pegs), and distance to move (for moving pegs)
--  *********************/
local function Animator_SpawnPeg(self, x, y, pegType, angle, radius, moveType, elapsed, loopTime, endX, endY, value3, value4)

	-- First, check to see if we have an object to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.pegQueue[1];
	if obj then
		tremove(self.pegQueue, 1);
	else
		obj = self:CreateImage(0, 0, const.pegWidth, const.pegHeight, gameBoard.foreground);
		obj.isPeg = true;
		obj.texture:SetDrawLayer("Background");
		obj.texture:SetTexCoord(0,0.5,0,0.5);
	end

	-- Set the texture
	if (PeggleData.settings.colorBlindMode) then
		obj.texture:SetTexture(const.artPath .. "pegs_");
	else
		obj.texture:SetTexture(const.artPath .. "pegs");
	end
	obj.texture:SetTexCoord(0 + ((pegType - 1) * 0.25), (pegType * 0.25),0,0.5);

	self:SetupObject(obj, x, y, pegType, angle, radius, moveType, elapsed, loopTime, endX, endY, value3, value4)

	return obj;
	
end

-- /***********************************************
--   Animator_SpawnGlow
--	 Spawns a glow segment that is anchored to a specified piece
--  *********************/
local function Animator_SpawnGlow(self, parent, crit, texture)

	-- First, check to see if we have an object to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.glowQueue[1];
	if obj then
		tremove(self.glowQueue, 1);
	else
		obj = self:CreateImage(0, 0, 32, 32, gameBoard);
		obj:SetTexture(const.artPath .. "hitGlow");
		obj:SetDrawLayer("Overlay");
		obj.texture = nil;
	end

	-- Set the texture
	obj:ClearAllPoints();
	obj:SetPoint("Center", parent, "Center");
	obj:SetHeight(32);
	obj:SetWidth(32);
	obj:SetAlpha(0.5);
	obj:Show();
	obj.elapsed = 0;

	if (texture == 1) or (texture == 2) then
		obj.texture = texture;
		if (texture == 1) then
			obj:SetVertexColor(1,0,1);
			obj:SetTexture("Spells\\AURARUNE9.BLP");
			obj:SetBlendMode("ADD");
		else
			obj:SetVertexColor(1,1,1);
			obj:SetTexture("Interface\\SpellShadow\\Spell-Shadow-Acceptable.blp");
			obj:SetBlendMode("ADD");
		end
		obj:SetWidth((thePegRadius * 9) * texture);
		obj:SetHeight((thePegRadius * 9) * texture);
		obj:SetAlpha(0.66);
		obj.startSize = (thePegRadius * 9) * texture;
		obj.endSize = 0; --(thePegRadius * 20) * texture;
	else
		if (obj.texture) then
			obj.texture = nil;
			obj:SetTexture(const.artPath .. "hitGlow");
		end
		obj:SetBlendMode("ADD");
		if crit then
			obj:SetVertexColor(1,1,0);
			obj:SetWidth(60);
			obj:SetHeight(60);
			obj.startSize = 60;
			obj.endSize = 120;
		else
			obj.startSize = 32;
			obj.endSize = 64;
			if (parent.id == PEG_BLUE) then
				obj:SetVertexColor(0.4,0.4,1);
			elseif (parent.id == PEG_RED) then
				obj:SetVertexColor(1,0.4,0.4);
			elseif (parent.id == PEG_GREEN) then
				obj:SetVertexColor(0.4,1,0.4);
			else
				obj:SetVertexColor(1,0.4,1);
			end
		end
	end
	
	tinsert(self.activeGlows, obj);
	return obj;
	
end

-- /***********************************************
--   Animator_SpawnParticle
--	 Spawns a particle at the specified x and y location, with specified colors (or none for random), speed, etc
--  *********************/
local function Animator_SpawnParticle(self, x, y, life, angle, speed, gravity, particleType, r, g, b)

	-- First, check to see if we have an object to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.particleQueue[1];
	if obj then
		tremove(self.particleQueue, 1);
		obj:SetTexture(const.artPath .. particleType);
	else
		obj = self:CreateImage(0, 0, 32, 32, gameBoard.foreground);
		obj:SetTexture(const.artPath .. particleType);
		obj:SetDrawLayer("Overlay");
		obj.texture = nil;
	end

	local colors = const.starColors
	-- Set the texture
	obj:ClearAllPoints();
	obj:SetPoint("Center", gameBoard, "BottomLeft", x, y);
	obj:SetAlpha(1);
	obj:Show();
	obj.elapsed = 0;
	obj.life = life;
	obj.x = x;
	obj.y = y;
	obj.gravity = gravity;
	obj.xVel = speed * cos(rad(angle));
	obj.yVel = speed * sin(rad(angle));
	obj.angle = random(0, 359);
	if (r) then
		obj:SetVertexColor(r, g, b);
	else
		local i = random(0, #colors/3-1);
		obj:SetVertexColor(colors[i * 3 + 1], colors[i * 3 + 2], colors[i * 3 + 3]); --irandom(3, 16)*16/255, random(3, 16)*16/255, random(3, 16)/255);
	end

	tinsert(self.activeParticles, obj);
	return obj;
	
end

-- /***********************************************
--   Animator_SpawnParticleGenerator
--	 Spawns a particle generator that shoots stars or sparks
--  *********************/
local function Animator_SpawnParticleGen(self, x, y, life, particleLife, spawnRate, startAngle, endAngle, minSpeed, maxSpeed, gravity, particleType, r, g, b)
-- /script animator:SpawnParticleGen(250, 0, 5, 1.2, 0.03, 80, 100, 30, 40, -2, "star"); animator:SpawnParticleGen(250, 0, 5, 1.2, 0.015, 80, 100, 20, 40, -2, "spark")
	-- First, check to see if we have an object to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.particleGenQueue[1];
	if obj then
		tremove(self.particleGenQueue, 1);
	else
		obj = {};
	end

	obj.life = life;
	obj.x = x;
	obj.y = y;
	obj.elapsed = 0;
	obj.spawnRate = spawnRate;
	obj.spawnElapsed = spawnRate;
	obj.startAngle = startAngle;
	obj.endAngle = endAngle;
	obj.minSpeed = minSpeed;
	obj.maxSpeed = maxSpeed;
	obj.particleType = particleType;
	obj.particleLife = particleLife;
	obj.r = r;
	obj.g = g;
	obj.b = b;
	obj.gravity = gravity;

	tinsert(self.activeParticleGens, obj);
	return obj;
	
end

-- /***********************************************
--   Animator_SpawnText
--   Spawns point text starting center location a little bit above the source obj.
--  *********************/
local function Animator_SpawnText(self, srcObj, point, r, g, b, xVel, yVel, x, y, showDelay, critText)

	-- First, check to see if we have an object to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.pointTextQueue[1];
	if obj then
		tremove(self.pointTextQueue, 1);
	else
		obj = gameBoard.foreground:CreateFontString(nil, "Overlay");
		obj:SetFont(const.artPath .. "OVERLOAD.ttf", 12, "Outline");
		obj:SetTextColor(1, 1, 0);
		obj.elapsed = 0;
		obj.Update = self.Update_FloatingText;
	end

	x = x or srcObj.x;
	y = y or (srcObj.y - 15);

	obj.elapsed = 0;
	obj:SetText(point);
	obj:SetTextColor((r or 1), (g or 1), (b or 0)); -- Default points are yellow
	obj:SetAlpha(1);
	
	-- Reset this text if it was a crit text
	if obj.critText then
		obj:SetFont(const.artPath .. "OVERLOAD.ttf", 12, "Outline");
	end
	obj.critText = critText;

	-- Now, add crit text if we need to
	if obj.critText then
		obj:SetFont(const.artPath .. "OVERLOAD.ttf", 24, "Outline");
--		obj:SetFont(NumberFontNormalHuge:GetFont());
		obj:SetTextColor(1, .5, 0)
	end

	-- Ensure text does not go outside the view boundry
	local width = obj:GetStringWidth();
	if (x > 250) then
		if (x + width/2) > const.boardWidth then
			x = const.boardWidth - width/2 - 8;
		end
	else
		if (x - width/2) < 0 then
			x = width/2 + 8;
		end
	end

	obj:SetPoint("Center", gameBoard, "BottomLeft", x, y);
	obj.x = x;
	obj.y = y;

	if (xVel) then
		obj.xVel = xVel;
		obj.yVel = yVel;
		obj.xOffset = 0;
		obj.yOffset = 0;
		obj.parent = srcObj;
		obj.displayTime = 1;
	else
		obj.xVel = nil;
		obj.yVel = nil;
		obj.xOffset = nil;
		obj.yOffset = nil;
		obj.parent = nil;
		obj.displayTime = 0.4
	end

	tinsert(self.activePointTextStack, obj);
	obj:Show();
	if (showDelay) then
		obj:SetAlpha(0);
		obj.elapsed = -showDelay;
		obj.delayed = true;
	end

	return obj;
	
end

-- /***********************************************
--   Animator_SpawnBrick
--	 Spawns a brick with a starting center location (x,y), desired
--   angle to be rendered at, and circle radius if it is a curved brick
--  *********************/
local function Animator_SpawnBrick(self, x, y, pegType, angle, radius, moveType, elapsed, loopTime, endX, endY, value3, value4)

	-- First, check to see if we have an object to recycle. If so, use
	-- it and remove it from the queue. Otherwise, create a new one.

	local obj = self.brickQueue[1];
	if obj then
		tremove(self.brickQueue, 1);
	else
		obj = self:CreateImage(0, 0, const.brickWidth, const.brickHeight, gameBoard.foreground);
		obj.isBrick = true;
		obj.texture:SetTexture(const.artPath .. "blueBrick1");
		obj.texture:SetDrawLayer("Background");
	end

	-- Set the correct texture
	local colorBlind = "";
	if (PeggleData.settings.colorBlindMode) and (pegType ~= PEG_RED) then
		colorBlind = "_";
	end
	obj.texture:SetTexture(const.artPath .. const.brickTex[pegType] .. "Brick" .. const.curvedBrick[radius] .. colorBlind);

	self:SetupObject(obj, x, y, pegType, angle, radius, moveType, elapsed, loopTime, endX, endY, value3, value4)

	return obj;
	
end

local function Update_FloatingText(self, elapsed)

	local hidden;

	self.elapsed = self.elapsed + elapsed;

	if (self.elapsed >= 0) then

		if (self.delayed) then
			self:SetAlpha(1);
			self.delayed = nil;
		end
	
		if (self.xVel) then
			self.xOffset = self.xOffset + elapsed * self.xVel;
			self.yOffset = self.yOffset + elapsed * self.yVel;
			self:SetPoint("Center", gameBoard, "BottomLeft", self.x + self.xOffset, self.y + self.yOffset);
		end

		if (self.elapsed >= self.displayTime) then
			if (self.elapsed >= self.displayTime + 0.2) then
				self:Hide();
				self.elapsed = 0;
				tinsert(animator.pointTextQueue, self);
				hidden = true;
			else
				self:SetAlpha(1 - ((self.elapsed - self.displayTime)/ 0.2));
			end
		end

	end

	return hidden;
	
end

local function DrawLine(x1, y1, x2, y2)
	
	numLines = numLines + 1;
	local line;
	if (numLines > (totalLines or (0))) then
		line = gameBoard.foreground:CreateTexture("polyLine"..numLines, "OVERLAY");
		if (const.debugMode) then
			line:SetTexture(const.artPath .. "editorLine");
		else
			line:SetTexture(const.artPath .. "pathLine");
		end
		line:SetVertexColor(0.3,0.7,1);
		line:SetAlpha(0.8);
		totalLines = numLines
	else
		line = getglobal("polyLine"..numLines);
	end
		
	if ( line ) then
		DrawRouteLine(line, gameBoard, x1, y1, x2, y2, 32);
		line:Show();
	end
	
end

local function DrawPathSquareCircle(x, y, angle, pieceType)
	
	numPathPieces = numPathPieces + 1;
	local obj;
	if (numPathPieces > (totalPathPieces or (0))) then
		obj = gameBoard.foreground:CreateTexture("pathPiece"..numPathPieces, "OVERLAY");
		obj:SetWidth(16);
		obj:SetHeight(16);
		obj:ClearAllPoints();
		totalPathPieces = numPathPieces
	else
		obj = getglobal("pathPiece"..numPathPieces);
	end
	if (obj) then
		obj:SetTexture(const.artPath .. "path" .. pieceType);
		obj:SetPoint("center", gameBoard, "Bottomleft", x, y);
		obj:Show();
		animator:RotateTexture(obj, angle, 0.5, 0.5)
	end
	
end

local function CollisionCheck_CircleOnCircle(x1, y1, rad1, x2, y2, rad2, obj1, obj2, stillBall, ignoreHit)

--	local dx = (x2 - x1);
--	local dy = (y2 - y1);
	local collisionDistance = rad1 + rad2;
	local actualDistanceSquared = (x2 - x1)^2 + (y2 - y1)^2;
	local expectedDistanceSquared = collisionDistance^2;
	local removed

--	dy = (checkObj.y - obj.y);
--	distance = sqrt(dx^2 + dy^2);

	local hit, collisionAngle;

	-- If the two circles are touching or into each other, we have a collision.
	if (actualDistanceSquared <= expectedDistanceSquared) then

		-- Calculate how far into the collision we are:
--		intoCollisionDistance = collisionDistance - sqrt(actualDistanceSquared);

--		local initialAngle = mod(atan2(ball.y - obj.y, ball.x - obj.x) + 360, 360);
--		local actualDistance = sqrt(actualDistanceSquared);
--		local colX = x2 + expectedDistance * cos(initialAngle);
--		local colY = y2 * sin(initialAngle);
--		obj1.x = colX;
--		obj1.y = colY;
		local actualDistance = sqrt(actualDistanceSquared)
		local collNormalAngle = atan2(y2-y1, x2-x1)
		-- position exactly touching, no intersection
		local moveDist1=(collisionDistance-actualDistance) *(101/(0+100))
--		local moveDist2=(collisionDistance-actualDistance)*(1/(1 + 1))
		local radians180 = rad(collNormalAngle + 180)
		obj1.x = obj1.x + moveDist1 * cos(radians180);
		obj1.y = obj1.y + moveDist1 * sin(radians180);
--		obj2.x = obj2.x + moveDist2 * cos(rad(collNormalAngle));
--		obj2.y = obj2.y + moveDist2 * sin(rad(collNormalAngle));
		-- COLLISION RESPONSE
		-- n = vector connecting the centers of the balls.
		-- we are finding the components of the normalised vector n
--		collNormalAngle = atan2(obj.y-y2, obj.x-x2)

		local radians = rad(collNormalAngle);
		local nX = cos(radians)
		local nY = sin(radians)

		-- now find the length of the components of each movement vectors
		-- along n, by using dot product.
		local a1 = obj1.xVel * nX  +  obj1.yVel * nY
--		local a2 = 0; --c2.dx*nX +  c2.dy*nY
		--		' optimisedP = 2(a1 - a2)
		--		'             ----------
		--		'              m1 + m2
--		local optimisedP = ((1 + ELASTICITY) * (a1-a2)) / (2); --10 + 10); --c.mass + c2.mass)
		local optimisedP = ((1 + ELASTICITY) * a1) / 2
--		local optimisedP = (a1); --10 + 10); --c.mass + c2.mass)
		-- now find out the resultant vectors
		-- '' Local r1% = c1.v - optimisedP * mass2 * n
		obj1.xVel = obj1.xVel - (optimisedP * 2 * nX)
		obj1.yVel = obj1.yVel - (optimisedP * 2 * nY)
--PHYSICS
if (abs(obj1.xVel) < 80) and (obj1.yVel >= 0) and (obj1.yVel < 40) then
	obj1.yVel = 0;
end

		--'' Local r2% = c2.v - optimisedP * mass1 * n
--		c2.dx = c2.dx + (optimisedP*c.mass*nX)
--		c2.dy = c2.dy + (optimisedP*c.mass*nY)

		if not ignoreHit then
			slideComboCount = 0;
			if not (obj2.hit) then
				obj2.hit = true;
				if (obj2 == animator.lastPeg) then
					for j = 1, 30 do 
						obj1["trail" .. j].x = -100;
						obj1["trail" .. j].y = -100;
						obj1["trail" .. j]:Hide();
					end
					obj1.trail1:SetPoint("Center", -1000, -1000);
					obj1.trail1:Show();
				end
				ScoreCalculate(obj2);
				if (obj2.isPeg) then
					obj2.texture:SetTexCoord(0 + ((obj2.id - 1) * 0.25),(obj2.id * 0.25),0.5,1);
				elseif (obj2.isBrick) then
					local colorBlind = "";
					if (PeggleData.settings.colorBlindMode) and (obj2.id > PEG_RED) then
						colorBlind = "_";
					end
					obj2.texture:SetTexture(const.artPath .. const.brickTex[obj2.id] .. "Brick" .. const.curvedBrick[obj2.radius] .. "a" .. colorBlind);
				end
			end
			obj2.hitCount = obj2.hitCount + 1;
			if (obj2.hitCount > 90) then
				stillBall = true;
			end
			lastPeg = obj2;

			if (stillBall) then
				GameObjectRemove(obj2);
				obj2:Hide();
				removed = true;
			end
		end

		hit = true;

	end

	return hit, removed;

end

local function CollisionCheck_CircleOnPolygon(x1, y1, rad1, x2, y2, rad2, obj1, obj2)

	local poly = const.polyTable;

	local collisionDistance = rad1 + rad2;
	local ballDistanceSquared = (rad1 - 1)^2;
	local actualDistanceSquared = (x2 - x1)^2 + (y2 - y1)^2;
	local expectedDistanceSquared = collisionDistance^2;
	local collide;
	local polyInfo = hitPolyInfo;

	-- If we're within hitting distance of this polygon, continue
	if (actualDistanceSquared <= expectedDistanceSquared) then

		-- Fill our polygon table with the values of this brick for checking
		local maxPoly = FillPolyTable(obj2);

		local checkBricks = true;
		local segment, px1, py1, px2, py2, dxSeg, dySeg, centerX, centerY
		local pDist, q, hitSeg;
		local bestDist = 100;
		local hitAngle;
		local pDistX, pDistY
		local vertexID;
		local corner = const.polygonCorners[const.curvedBrick[obj2.radius]];
		local edgeHitCheck = 0;
		
		local checkVector1X, checkVector1Y, checkVector2X, checkVector2Y, dotProduct, lineNormalX, lineNormalY, lineLength, newVectorX, newVectorY
		local edgeDistX, edgeDistY, edgeDist, edgeBestObj, edgeBestCenterX, edgeBestCenterY, edgeCenterX, edgeCenterY, edgeDxSeg, edgeDySeg, edgeHitAngle, edgeBallAngle, edgeBestDist, edgeHitSeg, edgeMaxPoly;

		px2 = poly[maxPoly - 1];
		py2 = poly[maxPoly];

		for segment = 1, maxPoly, 2 do 
			px1 = px2;
			py1 = py2;
			px2 = poly[segment];
			py2 = poly[segment+1];

			dxSeg = px2 - px1;
			dySeg = py2 - py1;
														
			q = ((x1 - px1) * (dxSeg) + (y1 - py1) * (dySeg)) / (dxSeg^2 + dySeg^2);
														
			if (q < 0) then
				q = 0;
			elseif (q > 1) then
				q = 1;
			end

			centerX = (1 - q) * px1 + q * px2;
			centerY = (1 - q) * py1 + q * py2;
														
			pDistX = (x1 - centerX)^2
			pDistY = (y1 - centerY)^2
			pDist = pDistX + pDistY

			if (pDist < (ballDistanceSquared)) then -- - 4) then
--				if (pDist <= polyInfo.bestDist) then

					-- Check the corners of this line segment to see if they hit
					-- the ball instead
					vertexID = floor((segment + 1) / 2);

					newVectorX = nil;

					if (vertexID == corner[1]) or (vertexID == corner[2]) or (vertexID == corner[3]) or (vertexID == corner[4]) then

--					if ((segment+1)/2 == const.polygonCorners[maxPoly]) then
--						if (((px1-x1)^2 + (py1-y1)^2) < 5) then --25
--							polyInfo.bestDist = -1;
--							polyInfo.centerX = px1;
--							polyInfo.centerY = py1;
--						elseif (((px2-x1)^2 + (py2-y1)^2) < 5) then
--							polyInfo.bestDist = -1;
--							polyInfo.centerX = px2;
--							polyInfo.centerY = py2;
--						end
--					end

--						lineLength = max(sqrt(dxSeg * dxSeg + dySeg * dySeg), 0.001);
						lineLength = sqrt(dxSeg * dxSeg + dySeg * dySeg);
						lineNormalX = dxSeg / lineLength;
						lineNormalY = dySeg / lineLength;
						checkVector1X = x1 - px1;
						checkVector1Y = y1 - py1;
						dotProduct = checkVector1X * lineNormalX + checkVector1Y * lineNormalY;

						if (dotProduct < 0) then
--							if (((px1-x1)^2 + (py1-y1)^2) < 9) then --25
								newVectorX = checkVector1X;
								newVectorY = checkVector1Y;
								centerX = px1;
								centerY = py1;
--							end
						else
							checkVector2X = x1 - px2;
							checkVector2Y = y1 - py2;
							dotProduct = checkVector2X * lineNormalX + checkVector2Y * lineNormalY;
							if (dotProduct > 0) then
--								if (((px2-x1)^2 + (py2-y1)^2) < 9) then --25
									newVectorX = checkVector2X;
									newVectorY = checkVector2Y;
									centerX = px2;
									centerY = py2;
--								end
							else
									
								-- project vector
	--							dotProduct = checkVector1X * lineNormalX + checkVector1Y * lineNormalY;
	--							newVectorX = dotProduct * lineNormalX;
	--							newVectorY = dotProduct * lineNormalY;
							end
						end

					end

					if (newVectorX) then
						if (edgeHitCheck == 0) then
							edgeHitCheck = 1;
							edgeDistX = (x1 - centerX+1)^2  -- 1
							edgeDistY = (y1 - centerY+1)^2  -- 1
							edgeDist = edgeDistX + edgeDistY
							edgeBestObj = obj2;
							local collNormalAngle = mod(atan2(newVectorY, newVectorX) + 360, 360);
							local ballVelocitySum = sqrt(obj1.xVel * obj1.xVel + obj1.yVel * obj1.yVel) * (0.75);
							local newAngle = mod(atan2(newVectorY, newVectorX) + 360, 360);
							edgeBestCenterX = centerX;
							edgeBestCenterY = centerY;
							edgeCenterX = centerX;
							edgeCenterY = centerY;
							edgeDxSeg = dxSeg;
							edgeDySeg = dySeg
							edgeHitAngle = collNormalAngle + 90;
							edgeBallAngle = mod(atan2(obj1.yVel, obj1.xVel) + 360, 360);
							edgeBestDist = edgeDist;
							edgeHitSeg = segment;
							edgeMaxPoly = maxPoly;
						else
							pDistX = (x1 - centerX+1)^2  -- 1
							pDistY = (y1 - centerY+1)^2  -- 1
							pDist = pDistX + pDistY
							if (pDist <= edgeDist) then
								polyInfo.bestObj = obj2;
								local collNormalAngle = mod(atan2(newVectorY, newVectorX) + 360, 360);
								local ballVelocitySum = sqrt(obj1.xVel * obj1.xVel + obj1.yVel * obj1.yVel) * (0.75);
								local newAngle = mod(atan2(newVectorY, newVectorX) + 360, 360);
								polyInfo.bestCenterX = centerX;
								polyInfo.bestCenterY = centerY;
								polyInfo.centerX = centerX;
								polyInfo.centerY = centerY;
								polyInfo.pDistX = pDistX
								polyInfo.pDistY = pDistY
								polyInfo.dxSeg = dxSeg;
								polyInfo.dySeg = dySeg
								polyInfo.hitAngle = collNormalAngle + 90;
								polyInfo.ballAngle = mod(atan2(obj1.yVel, obj1.xVel) + 360, 360);
								polyInfo.bestDist = pDist;
								polyInfo.hitSeg = segment;
								polyInfo.maxPoly = maxPoly;
							else
								polyInfo.bestObj = edgeBestObj;
								polyInfo.bestCenterX = edgeBestCenterX;
								polyInfo.bestCenterY = edgeBestCenterY;
								polyInfo.centerX = edgeCenterX;
								polyInfo.centerY = edgeCenterY;
								polyInfo.pDistX = edgeDistX
								polyInfo.pDistY = edgeDistY
								polyInfo.dxSeg = edgeDxSeg;
								polyInfo.dySeg = edgeDySeg
								polyInfo.hitAngle = edgeHitAngle;
								polyInfo.ballAngle = edgeBallAngle;
								polyInfo.bestDist = edgeBestDist;
								polyInfo.hitSeg = edgeHitSeg;
								polyInfo.maxPoly = edgeMaxPoly;
							end
							obj1.gravMultiplier = 0;
							break;
						end
					else
				if (pDist <= polyInfo.bestDist) then
						
						polyInfo.bestObj = obj2;
						polyInfo.bestDist = pDist;
						polyInfo.hitSeg = segment;
						polyInfo.hitAngle = mod(atan2(dySeg, dxSeg) + 360, 360);
						polyInfo.ballAngle = mod(atan2(obj1.yVel, obj1.xVel) + 360, 360);
						polyInfo.bestCenterX = centerX;
						polyInfo.bestCenterY = centerY;
						polyInfo.dxSeg = dxSeg;
						polyInfo.dySeg = dySeg;
						polyInfo.pDistX = pDistX;
						polyInfo.pDistY = pDistY;
						polyInfo.centerX = centerX;
						polyInfo.centerY = centerY;
						polyInfo.maxPoly = maxPoly;

						obj.gravMultiplier = 0;
				end
					end

--[[

					if (newVectorX) then
--						if ((polyInfo.bestObj == nil) or (polyInfo.bestObj == obj2)) then
							pDistX = (x1 - centerX+1)^2  -- 1
							pDistY = (y1 - centerY+1)^2  -- 1
							pDist = pDistX + pDistY
							if (pDist <= polyInfo.bestDist) then
								polyInfo.bestObj = obj2;
								local collNormalAngle = mod(atan2(newVectorY, newVectorX) + 360, 360);
								local ballVelocitySum = sqrt(obj1.xVel * obj1.xVel + obj1.yVel * obj1.yVel) * (0.75);
								local newAngle = mod(atan2(newVectorY, newVectorX) + 360, 360);
								polyInfo.bestCenterX = centerX;
								polyInfo.bestCenterY = centerY;
								polyInfo.centerX = centerX;
								polyInfo.centerY = centerY;
								polyInfo.pDistX = pDistX
								polyInfo.pDistY = pDistY
								polyInfo.dxSeg = dxSeg;
								polyInfo.dySeg = dySeg
								polyInfo.hitAngle = collNormalAngle + 90;
								polyInfo.ballAngle = mod(atan2(obj1.yVel, obj1.xVel) + 360, 360);

								polyInfo.bestDist = pDist;
								polyInfo.hitSeg = segment;
								polyInfo.maxPoly = maxPoly; -- -1

								obj1.gravMultiplier = 0;
								break;
							end
--						end
					else
						polyInfo.bestObj = obj2;
						polyInfo.bestDist = pDist;
						polyInfo.hitSeg = segment;
						polyInfo.hitAngle = mod(atan2(dySeg, dxSeg) + 360, 360);
						polyInfo.ballAngle = mod(atan2(obj1.yVel, obj1.xVel) + 360, 360);
						polyInfo.bestCenterX = centerX;
						polyInfo.bestCenterY = centerY;
						polyInfo.dxSeg = dxSeg;
						polyInfo.dySeg = dySeg;
						polyInfo.pDistX = pDistX;
						polyInfo.pDistY = pDistY;
						polyInfo.centerX = centerX;
						polyInfo.centerY = centerY;
						polyInfo.maxPoly = maxPoly;

						obj.gravMultiplier = 0;

					end
--]]
--				end
			end
		end
	end
end

local function Collide_CircleOnPolygon(obj, polyInfo, stillBall, ignoreHit)

	local centerX = polyInfo.bestCenterX;
	local centerY = polyInfo.bestCenterY;
	local checkObj = polyInfo.bestObj;
	local pDistX = polyInfo.pDistX;
	local pDistY = polyInfo.pDistY;
	local dxSeg = polyInfo.dxSeg;
	local dySeg = polyInfo.dySeg;
	local hitAngle = polyInfo.hitAngle;
	local ballAngle = polyInfo.ballAngle;
	local pDist = polyInfo.bestDist;
	local hitSeg = polyInfo.hitSeg;
	local maxPoly = polyInfo.maxPoly;

	local pLength = sqrt(pDist);
	local normalX = pDistX / pLength;
	local normalY = pDistY / pLength;

	local ax = normalX;
	local ay = normalY;

	local normalAngle = hitAngle - 90 - 0.01;
--	local reflectedAngle = mod(normalAngle + 180 - 0.01, 360);
--	local newAngle = normalAngle - (ballAngle - reflectedAngle) - 0.01;
	local testAngle;
	local velocitySum1;
	local slideHelper;
--

--[[

	local incAngle = ballAngle;
	local surfaceAngle = hitAngle;
	local nAngle = surfaceAngle - 90;
	local iAngle = 360 - incAngle + surfaceAngle;
	local modifiedAngle = incAngle - 180
	local theOutgoingAngle = nAngle + modifiedAngle;
--	local theOutgoingAngle = nAngle - incAngle;
--]]
	local surfaceAngle = hitAngle;
	local nAngle = surfaceAngle - 90;
	local reflectedAngle = mod(nAngle + 180 - 0.01, 360);

	local vecNormalX = cos(rad(nAngle));
	local vecNormalY = sin(rad(nAngle));
	local dotVelX = -obj.xVel * vecNormalX;
	local dotVelY = -obj.yVel * vecNormalY;
	local dotVel = dotVelX + dotVelY;
	local reflectionX = (1 + ELASTICITY) * vecNormalX * dotVel;
	local reflectionY = (1 + ELASTICITY) * vecNormalY * dotVel;
	local newXVel = obj.xVel + reflectionX;
	local newYVel = obj.yVel + reflectionY;
	local newReflectedAngle = mod(atan2(newYVel, newXVel) + 360, 360);

	local testAngle

	newAngle = newReflectedAngle;
	normalAngle = surfaceAngle - 90;

--	if (maxPoly > 0) then
		if (ballAngle > newAngle) then
			if (ballAngle > 330) then
				if (abs(newAngle + 360 - ballAngle) / 2) < 25 then
					slideHelper = true;
					testAngle = (normalAngle-90)
				end
			else
				if (abs(newAngle - ballAngle) / 2) < 25 then
					slideHelper = true;
					testAngle = (normalAngle+90)
				end
			end
		else
			if (abs(newAngle - ballAngle) / 2) < 25 then
				slideHelper = true;
				testAngle = (normalAngle-90)
			end
		end
--	end
--[[			
	if (ballAngle <= reflectedAngle) then
		if (newAngle >= 360) then
		testAngle = (normalAngle-90)
	--printd(ballAngle .. " " .. newReflectedAngle .. " n: " .. normalAngle .. " testAngle: " .. testAngle .. " " .. (testAngle - newAngle));

			if (abs(newAngle - testAngle) < 25) or (abs(newAngle - testAngle) > 155) then
				slideHelper = true;
--			else
--				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		else
		testAngle = (normalAngle+90)
	--printd(ballAngle .. " " .. newReflectedAngle .. " n: " .. normalAngle .. " n+90: " .. (normalAngle+90) .. " " .. (testAngle - newAngle));
			if (abs(testAngle - newAngle) < 25) or (abs(testAngle - newAngle) > 155) then
				slideHelper = true;
--			else
--				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		end
	else
		if (newAngle >= 180) then --< 0) and (newAngle > -180) then
--			newAngle = newAngle + 360;
			if (ballAngle > 270) or (ballAngle < 90)  then
				if (normalAngle < 180) then
					testAngle = (normalAngle-90)
				else
					testAngle = (normalAngle+90)
				end
			else
				if (normalAngle < 180) then
					testAngle = (normalAngle-90)
				else
					testAngle = (normalAngle+90)
				end
			end
	--printd(ballAngle .. " " .. newReflectedAngle .. " n: " .. normalAngle .. " testAngle: " .. testAngle .. " " .. (testAngle - newAngle));
				
			if (abs(newAngle - testAngle) < 25) or (abs(newAngle - testAngle) > 335) then
				slideHelper = true;
--			else
--				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		else
		testAngle = (normalAngle-90)
	--printd(ballAngle .. " " .. newReflectedAngle .. " n: " .. normalAngle .. " testAngle: " .. testAngle .. " " .. (testAngle - newAngle));

			if (abs(testAngle - newAngle) < 25) or (abs(testAngle - newAngle) > 155) then
				slideHelper = true;
--			else
--				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		end

	end
--]]
	if (slideHelper == true) then
		newAngle = testAngle;
--		reflectionX = (1.98) * vecNormalX * dotVel;
--		reflectionY = (1.98) * vecNormalY * dotVel;
--		newXVel = obj.xVel + reflectionX;
--		newYVel = obj.yVel + reflectionY;
		velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * 0.98
		obj.xVel = velocitySum1 * cos(rad(newAngle));
		obj.yVel = velocitySum1 * sin(rad(newAngle));
	else
		slideComboCount = 0;
		obj.xVel = newXVel;
		obj.yVel = newYVel;
	end


--[[
	if (ballAngle <= reflectedAngle) then
		if (newAngle >= 360) then
		testAngle = (normalAngle-90)
			if (abs(newAngle - testAngle) < 25) or (abs(newAngle - testAngle) > 155) then
				slideHelper = true;
			else
				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		else
		testAngle = (normalAngle+90)
			if (abs(testAngle - newAngle) < 25) or (abs(testAngle - newAngle) > 155) then
				slideHelper = true;
			else
				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		end
	else
		if (newAngle < 0) and (newAngle > -180) then
			newAngle = newAngle + 360;
			if (ballAngle > 270) or (ballAngle < 90)  then
				if (normalAngle < 180) then
					testAngle = (normalAngle-90)
				else
					testAngle = (normalAngle+90)
				end
			else
				if (normalAngle < 180) then
					testAngle = (normalAngle-90)
				else
					testAngle = (normalAngle+90)
				end
			end
				
			if (abs(newAngle - testAngle) < 25) or (abs(newAngle - testAngle) > 335) then
				slideHelper = true;
			else
				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		else
		testAngle = (normalAngle-90)
			if (abs(testAngle - newAngle) < 25) or (abs(testAngle - newAngle) > 155) then
				slideHelper = true;
			else
				velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
			end
		end

	end

	local oldX, oldY = obj.xVel, obj.yVel;

	if (slideHelper == true) then --or (velocitySum1 <= 40) then
		newAngle = testAngle;
--		if (slideHelper) then
			velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * 0.98
--		else
--			velocitySum1 = abs(obj.yVel)
--		end
	else
		slideComboCount = 0;

	end

	obj.xVel = velocitySum1 * cos(rad(newAngle));
	obj.yVel = velocitySum1 * sin(rad(newAngle));

	if not slideHelper and ((abs(obj.xVel) < 20) and (obj.yVel >= 0) and (obj.yVel < 40)) then
		newAngle = testAngle;
		velocitySum1 = sqrt(oldX * oldX + oldY * oldY) * (ELASTICITY - 0.20) --1
		obj.xVel = velocitySum1 * cos(rad(newAngle));
		obj.yVel = velocitySum1 * sin(rad(newAngle));
	--	obj.yVel = 0;
	--	obj.xVel = 0;
	--	obj.x = centerX + cos(rad(normalAngle)) * (const.ballRadius + 0.1);
	--	obj.y = centerY + sin(rad(normalAngle)) * (const.ballRadius + 0.1);
	else
		-- Reposition the ball
	--	obj.x = centerX + cos(rad(normalAngle)) * (const.ballRadius + 0.1);
	--	obj.y = centerY + sin(rad(normalAngle)) * (const.ballRadius + 0.1);
	end
--]]

--PHYSICS
--	if (maxPoly == -1) then
--		obj.x = centerX + cos(rad(normalAngle)) * (const.ballRadius + 2.1);
--		obj.y = centerY + sin(rad(normalAngle)) * (const.ballRadius + 2.1);
--	else
		obj.x = centerX + cos(rad(normalAngle)) * (theBallRadius + 0.1);
		obj.y = centerY + sin(rad(normalAngle)) * (theBallRadius + 0.1);
--	end

	if not ignoreHit then

		if (slideHelper == true) then

			if (slideComboCount >= 2) then
				animator:SpawnParticle(centerX+1, centerY, 0.2, newAngle + 180, 10, -1, "spark")
				animator:SpawnParticle(centerX, centerY-1, 0.2, newAngle + 181, 8, -1, "spark")
				animator:SpawnParticle(centerX-1, centerY, 0.2, newAngle + 182, 6, -1, "spark")
				animator:SpawnParticle(centerX, centerY+1, 0.2, newAngle + 183, 9, -1, "spark")
				animator:SpawnParticle(centerX, centerY, 0.2, newAngle + 184, 7, -1, "spark")
			end
		end

		if not (checkObj.hit) then
			if (slideHelper == true) then
				slideComboCount = slideComboCount + 1;
				StyleShotCalculate(5, checkObj.x, checkObj.y);
			end
			if (checkObj == animator.lastPeg) then
				for j = 1, 30 do 
					obj["trail" .. j].x = -100;
					obj["trail" .. j].y = -100;
					obj["trail" .. j]:Hide();
				end
				obj.trail1:SetPoint("Center", -1000, -1000);
				obj.trail1:Show();
			end

			checkObj.hit = true;
			ScoreCalculate(checkObj);

			local colorBlind = "";
			if (PeggleData.settings.colorBlindMode) and (checkObj.id > PEG_RED) then
				colorBlind = "_";
			end
			checkObj.texture:SetTexture(const.artPath .. const.brickTex[checkObj.id] .. "Brick" .. const.curvedBrick[checkObj.radius] .. "a" .. colorBlind);
		end

		checkObj.hitCount = checkObj.hitCount + 1;
		if (checkObj.hitCount > 9) then
			stillBall = true;
		end

		lastPeg = checkObj;

		if (stillBall) then
			GameObjectRemove(checkObj);
			checkObj:Hide();
		end
	end

	polyInfo.bestObj = nil;

end

-- /***********************************************
--   Animator_OnUpdate
--
--   Update function that is ran every time the screen refreshes. This is the meat
--   of the animation engine. Note: The values passed to this function are automatically
--   generated by the OnUpdate script in WOW. The UI calls this function.
--
--   accepts:	self (object that has the function), arg1 (time since last update)
--   returns:	none
--  *********************/
local function Animator_OnUpdate(self, arg1)

	-- Update timer. If it's not time to update the animations, end now
	self.elapsed = self.elapsed + arg1;
	if (self.elapsed < self.delay) then
		return;
	end

	-- Don't update anything is the game is not shown.
	if not window:IsVisible() then
		self.elapsed = 0;
		return;
	end

	-- Calculate how much time has elapsed. However, if more time passed than we would have
	-- liked (due to crazy screen lag, loading, etc.), set the elapsed time to twice the
	-- update rate.
	self.elapsed = min(self.elapsed, self.elapsed) * GAME_SPEED; --self.delay * 2) * GAME_SPEED;

	if (const.speedy == true) then
		self.elapsed = self.elapsed * 3;
	end

	-- Calculate change in velocities based upon update frac (1/30 of a sec). Making this a smaller fraction
	-- will "slow down time" and increasing it will increase time.
	local updateFrac = 1/100;
	local deltaXVel = 0; -- * updateFrac;
	local deltaYVel = GRAVITY * updateFrac;
	
	local Sound = Sound;

	-- Grab the group of animated objects
	local db = self.animationStack;

	-- Grab the group of balls
	local ballDB = self.activeBallStack;

	local polyInfo = hitPolyInfo;

	-- Declare our locals for fun times.
	local obj, checkObj, i, j, k, index, ballIndex, iterate, sameXY;
	local distance, dx, dy, dt, ax, ay, velocitySum1, velocitySum2, ed;
	local collisionVelX1, collisionVelY1, collisionVelX2, collisionVelY2, newVelocityX1, newVelocityX2;
	local checkX, checkY, checkPegs, pegHitTotal
	local catcher = window.catcher;
	local stillBall;
	local steppedInto = 0;
	local catcherWidth = 10 + 40;
	local stats = const.stats;

	-- Ball updating

	-- Update the ball catcher position
	window.catcher:Update(self.elapsed);
	window.feverTracker:Update(self.elapsed);

	if (self.elapsedCount ~= slideComboCount) then
		self.elapsedCount = slideComboCount;
		self.elapsedCount2 = 0;
	elseif (self.elapsedCount ~= 0) then
		self.elapsedCount2 = self.elapsedCount2 + self.elapsed;
		if (self.elapsedCount2 > 0.05) then
			slideComboCount = 0;
			self.elapsedCount = 0;
		end
	end

	-- Update the position of all objects that are moving
	for index = 1, #db do 
		obj = db[index];
		self:UpdateMover(obj, self.elapsed);
	end

	-- Update the rainbow!
	if (self.feverUp) then
		if (self.feverUp > -1) then
			self.feverUp = self.feverUp + self.elapsed / GAME_SPEED;
			if (self.feverUp >= 0.5) then
				self.feverUp = -1;
				window.rainbow:SetWidth(gameBoard:GetWidth());
				window.rainbow:SetTexCoord(0,1,0,1);
				window.feverPegScore:Show();
				window.fever3:Show();
			else
				window.rainbow:SetWidth(gameBoard:GetWidth() * self.feverUp * 2);
				window.rainbow:SetTexCoord(1 - self.feverUp * 2, 1, 0, 1);
			end
		end
	end
	-- Update all glows in play
	i = 1;
	for index = 1, #self.activeGlows do 
		obj = self.activeGlows[i];
		if (obj.texture) then
			obj.elapsed = obj.elapsed + self.elapsed/3;
		else
			obj.elapsed = obj.elapsed + self.elapsed;
		end
				
		if (obj.elapsed > 0.3) then
			tinsert(self.glowQueue, obj);
			tremove(self.activeGlows, i);
			obj:Hide();
		else
			i = i + 1;
			j = obj.startSize + obj.endSize * obj.elapsed;
			obj:SetWidth(j)
			obj:SetHeight(j)
			if obj.texture then
				if (obj.elapsed > 0.2) then
					obj:SetAlpha(1 - ((obj.elapsed - 0.2)/0.1))
				end
			else
				obj:SetAlpha(0.6 - obj.elapsed*2)
			end					
		end
	end

	-- Update all particle generators in play
	i = 1;
	for index = 1, #self.activeParticleGens do 
		obj = self.activeParticleGens[i];
		obj.elapsed = obj.elapsed + self.elapsed;
		obj.spawnElapsed = obj.spawnElapsed + self.elapsed;
		if (obj.elapsed > obj.life) then
			tinsert(self.particleGenQueue, obj);
			tremove(self.activeParticleGens, i);
		else
			i = i + 1;
			if (obj.spawnElapsed > obj.spawnRate) then
				obj.spawnElapsed = 0;
				self:SpawnParticle(obj.x, obj.y, obj.particleLife, random(obj.startAngle, obj.endAngle), random(obj.minSpeed, obj.maxSpeed), obj.gravity, obj.particleType, obj.r, obj.g, obj.b);
			end
		end
	end

	-- Update all particles in play
	i = 1;
	for index = 1, #self.activeParticles do 
		obj = self.activeParticles[i];
		obj.elapsed = obj.elapsed + self.elapsed;
		if (obj.elapsed > obj.life + 0.2) then
			tinsert(self.particleQueue, obj);
			tremove(self.activeParticles, i);
			obj:Hide();
		else
			if (obj.elapsed > obj.life) then
				obj:SetAlpha(1 - ((obj.elapsed - obj.life) / 0.2));
			end
			obj.x = obj.x + obj.xVel * GAME_SPEED
			obj.y = obj.y + obj.yVel * GAME_SPEED;
			obj.yVel = obj.yVel + obj.gravity * GAME_SPEED;
			i = i + 1;
			obj.angle = obj.angle + 10;
			if (obj.angle >= 360) then
				obj.angle = obj.angle - 360;
			end
			self:RotateTexture(obj, obj.angle, 0.5, 0.5);
			obj:SetPoint("Center", gameBoard, "BottomLeft", obj.x, obj.y);
		end
	end

	-- Update any floating point text that is active
	index = 1;
	local finished;
	for i = 1, #self.activePointTextStack do 
		obj = self.activePointTextStack[index];
		finished = obj:Update(self.elapsed);
		if (finished) then
			tremove(animator.activePointTextStack, index);
		else
			index = index + 1;	
		end
	end
	catcher = catcher.x

	if (window.roundPegs.elapsed) then
		obj = window.roundPegs;
		obj.elapsed = obj.elapsed + self.elapsed;
		if (obj.elapsed >= 2) then
			obj:Hide();
			window.fever3:Hide();
			window.feverPegScore:Hide();
			window.roundPegScore:Hide();
			window.roundBonusScore:Hide();
			obj:SetAlpha(1);
			window.roundPegScore:SetAlpha(1);
			window.roundBonusScore:SetAlpha(1);
			obj.elapsed = nil;
			if (self.temp2) then
				if (self.temp1) then
					window.banner.tex:SetTexCoord(unpack(window.banner.tex["clear" .. self.temp1]));
					window.banner.tex:SetAlpha(0);
					window.banner.tex:Show();
					window.banner:Show();
					Sound(const.SOUND_APPLAUSE);
				else
					window.summaryScreen:Show();
				end
			end
		elseif (obj.elapsed > 1) and not self.feverUp then
			local alpha = 1 - (obj.elapsed - 1);
			obj:SetAlpha(alpha);
			window.roundPegScore:SetAlpha(alpha);
			window.roundBonusScore:SetAlpha(alpha);
		end
	end

	-- Reclaim (with effect) all hit pegs
	if (self.reclaim) then
		if (feverPegsHit == feverPegsTotal) and not self.feverUp then
			self.feverUp = 0;
			window.roundPegs:SetText("");
			window.roundPegScore:SetText("");
			window.roundBonusScore:SetText("");
			window.fever1:Hide();
			window.fever2:Hide();
			window.rainbow:Show();
			window.rainbow:SetTexCoord(1,1,0,1);
			window.rainbow:SetWidth(1);
		end
		if (not self.feverUp) or (self.feverUp == -1) then
			if (#self.hitPegStack > 0) then
				if not self.pegDelay then
					self.pegDelay = self.elapsed;
				else
					self.pegDelay = self.pegDelay + self.elapsed;
				end
				if (self.pegDelay >= 0.05) then
					self.pegDelay = nil;
					Sound(const.SOUND_PEG_POP);
					obj = tremove(self.hitPegStack, 1);
					obj:Hide();
					self.pegsHit = self.pegsHit + 1;

	--				if (mod(self.pegsHit, 2) == 1) then
						Sound(const.SOUND_SCORECOUNTER);
	--				end

					self:SpawnGlow(obj);
					if self.feverUp then
						window.feverPegScore:SetFormattedText("%s", NumberWithCommas(roundScoreTalents * self.pegsHit));
						window.feverPegScore:Show();
						window.roundPegs.elapsed = 0;
					else
						window.roundPegs:SetFormattedText(const.locale["_PEGS_HIT"], self.roundValue, self.pegsHit);
						window.roundPegScore:SetFormattedText("%s", NumberWithCommas(roundScoreTalents * self.pegsHit));
						window.roundPegs:Show();
						window.roundPegScore:Show();
						window.roundPegs.elapsed = 0;
					end
				end
			else
				if (self.pegsHit == 0) and (not self.freeBall) then

					window.roundPegScore:SetFormattedText("%s", const.locale["_TOTAL_MISS"]);
					window.roundPegScore:Show();

					-- Free ball coin only outside of Peggle Loot mode
					if not const[const.newInfo[13]] then
						Sound(const.SOUND_COIN_SPIN);
						self.coin.elapsed = 0;
						self.coin.side = 0;
						self.coin.flips = 0;
						self.coin.check = nil;
						self.spinStop = nil;
						self.coin:Show();
						freeBallCombo = 0;
					end
				else
	--				window.ballTracker:UpdateDisplay(1);
				end

				if (stats[5] == 0) then
					stats[4] = stats[4] + (roundScoreTalents * self.pegsHit) - (roundScore * self.pegsHit);
				else
					stats[5] = stats[5] + (roundScore * self.pegsHit);
				end

				if (bonusScore > 0) then
					window.roundBonusScore:SetFormattedText(const.locale["_STYLE_COUNT"], NumberWithCommas(bonusScoreTalents));
					window.roundBonusScore:Show();
					stats[6] = stats[6] + bonusScore;
				end

				window.ballTracker:UpdateDisplay(3);
	--			window.feverTracker:UpdateDisplay(2);
				totalScore = totalScore + currentScore + bonusScoreTalents;

				if (self.feverUp) then
					stats[5] = stats[5] + ballCount * (2344 + 7656);
					local stack = window.ballTracker.ballStack;
					for i = 1, #stack do 
						animator:SpawnText(nil, const.locale["_BALL_SCORE"], 0.4, 1, 1, 0, 40, 0, stack[i].y + 40, 0);
						stack[i]:Hide();
					end
					window.feverPegScore:SetFormattedText("%s", NumberWithCommas(stats[5]));
					window.feverPegScore:Show();
					window.roundBonusScore:Hide();
				end

				currentScoreText:SetText(NumberWithCommas(totalScore));
				roundScore = 0;
				roundScoreTalents = 0;
				currentScore = 0;
				bonusScore = 0;
				bonusScoreTalents = 0;
				if (not self.freeBall) and (self.pegsHit > 0) and (feverPegsHit < feverPegsTotal) then --(not window.feverTracker.barFlashUpdate) and (feverPegsHit < 25) then
					window.ballTracker:UpdateDisplay(1);
				end
				self.freeBall = nil;
				self.reclaim = nil;
				ReclaimPegs();
			end
		end
	end

	-- Update the free ball display text, if it's active
	if (self.freeElapsed) then
--		local obj = window.ballTracker;
		self.freeElapsed = self.freeElapsed + self.elapsed;
		if (self.freeElapsed >= 0.5) then
			self.freeState = self.freeState + 1;
			self.freeElapsed = 0;
			if (self.freeState == 7) then
				window.ballTracker.freeDisplay1:Hide();
				window.ballTracker.freeDisplay2:Hide();
				window.ballTracker.freeDisplayGlow:Hide();
				window.ballTracker.ballDisplay:Show();

				self.freeElapsed = nil;
				self.freeState = 0;
			elseif (self.freeState < 5) then
				
				if (mod(self.freeState, 2) == 0) then
					window.ballTracker.freeDisplay1:Show();
					window.ballTracker.freeDisplay2:Hide();
				else
					window.ballTracker.freeDisplay1:Hide();
					window.ballTracker.freeDisplay2:Show();
				end
			end			
		else
			if (self.freeState == 6) then
				window.ballTracker.freeDisplay1:SetAlpha((0.5 - self.freeElapsed) / 0.5);
				window.ballTracker.freeDisplayGlow:SetAlpha((0.5 - self.freeElapsed) / 0.5);
			end	
		end
	end

	if (shooterReady) then
--		gameBoard.background:Hide();
		if (ANGLE ~= lastAngle) then
--			lastAngle = ANGLE;

			local lineID;
			for lineID = 1, numLines do 
				getglobal("polyLine"..lineID):Hide();
			end
			for lineID = 1, numPathPieces do 
				getglobal("pathPiece"..lineID):Hide();
			end
			
			local totalTime = 0;
			obj = fakeBall;

			obj.x = const.boardWidth / 2 + 1;
			obj.y = const.boardHeight - 16 - 20;

			obj.xVel = cos(rad(ANGLE)) * SHOOT_FORCE;
			obj.yVel = sin(rad(ANGLE)) * SHOOT_FORCE;

			local xx, yy = obj.x, obj.y
			polyInfo.bestDist = 100;

			local collide = false;
			local bestDist = 1000;
			local checkBricks = false;

			local maxPoly;
			local px1, px2, py1, py2, segment, dxSeg, dySeg, q, centerX, centerY;
			local poly = const.polyTable;
			local bestCenterX, bestCenterY;
			local bestObj;
			local lastX, lastY;
			local bestVertex = 0;
			local hitSeg = 0;
			local hitAngle = 0;
			local ballAngle = 0;

			local pathTime = -0.20 -(abs(270 - SHOOTER_ANGLE)/110 * 0.15);
			if (SHOOTER_ANGLE < 90) then
				pathTime = -0.20 -(abs(270 - 360 + SHOOTER_ANGLE)/110 * 0.15);
			end
			local prevHit
			pegHitTotal = 0;
			local lastPegHitTotal = 0;

			numLines = 0;
			numPathPieces = 0;

			while ((totalTime < 10) and (obj.y > 0) and (pegHitTotal < GUIDE_HITS) ) do
				-- Update the ball's position
				
				xx, yy = obj.x, obj.y

				obj.x = obj.x + (obj.xVel * updateFrac);
				obj.y = obj.y + (obj.yVel * updateFrac);
				totalTime = totalTime + updateFrac;

				checkPegs = true
				
				polyInfo.bestDist = 100;

				-- Check if it hit any pegs
				checkX, checkY = GameObjectCoordLocation(obj.x, obj.y);
				if (checkX) then
					for j = checkY- 1, checkY + 1 do 
						if (j > 0) and (j <= const.boardXYSections) then
							for i = checkX - 1, checkX + 1 do 
								if (i > 0) and (i <= const.boardXYSections) then

									for k = 1, #gameObjectDB[j][i] do 

										-- Grab the peg to be checked and calculate the distance between
										-- the peg and the ball.
										checkObj = gameObjectDB[j][i][k];

										-- Peg collision check
										if (checkObj.isPeg) then
											prevHit = CollisionCheck_CircleOnCircle(obj.x, obj.y, theBallRadius, checkObj.x, checkObj.y, thePegRadius, obj, checkObj, nil, true);
											if (prevHit) then
												if (showGuide) then
													DrawLine(xx, yy, obj.x, obj.y);
												end
--													xx, yy = obj.x, obj.y
												pegHitTotal = pegHitTotal + 1;
											end
										elseif (checkObj.isBrick) then
											CollisionCheck_CircleOnPolygon(obj.x, obj.y, theBallRadius, checkObj.x, checkObj.y, theBrickRadius, obj, checkObj);
--[[
											if (polyInfo.bestObj) then
												pegHitTotal = pegHitTotal + 1;
												if (polyInfo.bestDist == -1) then
													CollisionCheck_CircleOnCircle(obj.x, obj.y, const.ballRadius, polyInfo.centerX, polyInfo.centerY, 1, obj, polyInfo.bestObj, nil, true);
													polyInfo.bestObj = nil;
												else
													Collide_CircleOnPolygon(obj, polyInfo, nil, true);
												end
												if (showGuide) then
													DrawLine(xx, yy, obj.x, obj.y);
												end
--													xx, yy = obj.x, obj.y
											end
--]]
										end
									end
								end
							end
						end
					end
--
					if (polyInfo.bestObj) then
						pegHitTotal = pegHitTotal + 1;
						if (polyInfo.bestDist == -1) then
							CollisionCheck_CircleOnCircle(obj.x, obj.y, theBallRadius, polyInfo.centerX, polyInfo.centerY, 1, obj, polyInfo.bestObj, nil, true);
							polyInfo.bestObj = nil;
						else
							Collide_CircleOnPolygon(obj, polyInfo, nil, true);
						end
						if (showGuide) then
							DrawLine(xx, yy, obj.x, obj.y);
						end
--													xx, yy = obj.x, obj.y
					end
--
				end

				if (showGuide) then
					if (lastPegHitTotal == pegHitTotal) then
						DrawLine(xx, yy, obj.x, obj.y);
					end
				end

				pathTime = pathTime + updateFrac;
				if (pathTime > 0.04) or (lastPegHitTotal ~= pegHitTotal) then
					pathTime = 0;
					if (pegHitTotal ~= lastPegHitTotal) then
						DrawPathSquareCircle( obj.x,  obj.y, floor(atan2(obj.yVel, obj.xVel) or (0)) + 135 , "Circle");
					else
						if not showGuide then
							if (numPathPieces == 9) then
								DrawPathSquareCircle(xx, yy, floor(atan2(obj.yVel, obj.xVel) or (0)) + 135, "Edge");
							else
								DrawPathSquareCircle(xx, yy, floor(atan2(obj.yVel, obj.xVel) or (0)) + 135, "Square");
							end
							if (numPathPieces > 9) and (GUIDE_HITS <= 2) then
								totalTime = 11;
							end

						end
					end
				end
				lastPegHitTotal = pegHitTotal;

				if (numLines > 240) and (GUIDE_HITS <= 2) then
					totalTime = 11;
				end

				-- Check for bounce on left and right walls
				if (obj.x < const.boardBoundryLeft) then
					obj.x = const.boardBoundryLeft + (const.boardBoundryLeft - obj.x);
					obj.xVel = -obj.xVel - (deltaXVel);
				elseif (obj.x > const.boardBoundryRight) then
					obj.x = const.boardBoundryRight - (obj.x - const.boardBoundryRight);
					obj.xVel = -obj.xVel - (deltaXVel);
				end

				-- No bounce on the bottom, it just disappears (get's SWALLOWED!)
				if (obj.y < (const.boardBoundryBottom - 10)) then
					obj.y = -100;
					obj.yVel = 0;
				-- Bounce on the top wall...
				elseif (obj.y > const.boardBoundryTop) then
					obj.y = const.boardBoundryTop - (obj.y - const.boardBoundryTop);
					obj.yVel = -obj.yVel;
				end

				-- Adjust the velocities based upon air resistance (x velocity)
				-- If we get too little of a velocity, we need to make our object
				-- stop moving along the x axis.
				if (obj.y < theBallRadius * 2) then
					if (obj.xVel < 0) then
						obj.xVel = obj.xVel + deltaXVel;
					else
						obj.xVel = obj.xVel - deltaXVel;
					end
					if (abs(obj.xVel) < 2) then
						obj.xVel = 0;
					end
				else
					if (obj.xVel < 0) then
						obj.xVel = obj.xVel + deltaXVel;
					else
						obj.xVel = obj.xVel - deltaXVel;
					end
				end

				-- Adjust the velocities based upon gravity (y velocity)
				-- If we fall faster than gravity (ghetto terminal velocity code),
				-- set the velocity to the speed of gravity. If the velocity is
				-- too small, the object will come to a stop along the y axis
				-- (to rest on the ground, for example ... dirty code, I know)
				obj.yVel = obj.yVel + deltaYVel;
--				if (abs(obj.yVel) < 3) then
--					obj.yVel = 0;
--				end

			end

			if (showPoly) then
				
				local i;
				local maxPoly, segment;
				local poly = const.polyTable;
				for i = 1, #db do 
					obj = db[i];
					if (obj.isBrick) then
						maxPoly = FillPolyTable(obj);
						for segment = 1, (maxPoly - 2), 2 do 
							DrawLine(poly[segment], poly[segment + 1], poly[segment+2], poly[segment+3]);
						end
						DrawLine(poly[maxPoly - 1], poly[maxPoly], poly[1], poly[2]);
					end
				end
			end

		end
	else
--		local lineID;
--		for lineID = 1, numLines do 
--			getglobal("polyLine"..lineID):Hide();
--		end
	end

	-- Loop until our calculation step is greater than or equal to the
	-- time that passed between updates (to ensure accurate position
	-- updates, no matter what framerate the user is running with, woot!)
	while (steppedInto <= self.elapsed) do 

		index = 1;

		-- Run through all balls that need updating
		for iterate = 1, #ballDB do 

			-- Grab the current object
			obj = ballDB[index];

			-- If the object is a ball, we need to update it's location and
			-- so some hit detection
			if (obj.isBall) then

				obj.gravMultiplier = 1;

				-- Shuffle the trails down the group, so the new trail that
				-- generates is at the ball's current possition
				if (steppedInto == 0) then

					if (obj.trail1:IsShown()) then
						for j = 30, 2, -1 do 
							obj["trail" .. j].x = obj["trail" .. (j - 1)].x
							obj["trail" .. j].y = obj["trail" .. (j - 1)].y
						end
						obj.trail1.x = obj.x;
						obj.trail1.y = obj.y;
					end
--[[
					obj.trail4.x = obj.trail3.x
					obj.trail4.y = obj.trail3.y
					obj.trail3.x = obj.trail2.x
					obj.trail3.y = obj.trail2.y
					obj.trail2.x = obj.trail1.x
					obj.trail2.y = obj.trail1.y
					obj.trail1.x = obj.x;
					obj.trail1.y = obj.y;
--]]
--[[
					obj.lastVel3 = obj.lastVel2;
					obj.lastVel2 = obj.lastVel1;
					obj.lastVel1 = (obj.xVel^2 + obj.yVel^2)
					if (obj.lastVel3) then
						if (((obj.lastVel3 + obj.lastVel2 + obj.lastVel1) / 3) < 500) then
							stillBall = true;
							obj.lastVel1 = nil;
							obj.lastVel2 = nil;
							obj.lastVel3 = nil;
						end
					end
--]]
				end

				-- Update the ball's position
				obj.x = obj.x + (obj.xVel * updateFrac);
				obj.y = obj.y + (obj.yVel * updateFrac);

				-- Check if it hit any balls
				for ballIndex = 1, #ballDB do 

					-- We only want to compare against balls other than the
					-- current ball
					if (index ~= ballIndex) then

						-- Grab the ball to be checked and calculate the distance between
						-- the two.
						checkObj = ballDB[ballIndex];
						
						dx = (checkObj.x - obj.x);
						dy = (checkObj.y - obj.y);
						distance = sqrt(dx^2 + dy^2);

						-- If we are within hitting distance (the balls are closer than the sum
						-- of their radii), we have a collision.
						if (distance <= (theBallRadius*2)) then

							-- Calculate and sum the objects' components of velocity
							velocitySum1 = obj.xVel * dx / distance + obj.yVel * dy / distance;
							velocitySum2 = checkObj.xVel * dx / distance + checkObj.yVel * dy / distance;

							-- Calculate time of collision
							dt =(theBallRadius + theBallRadius - distance) / (velocitySum1 - velocitySum2);

							-- Reset position of balls to just before impact
							obj.x = obj.x - obj.xVel * dt;
							obj.y = obj.y - obj.yVel * dt;
							checkObj.x = checkObj.x - checkObj.xVel * dt;
							checkObj.y = checkObj.y - checkObj.yVel * dt;

							-- Calculate distance between balls with reset positions
							dx = checkObj.x - obj.x
							dy = checkObj.y - obj.y;
							distance = sqrt(dx^2 + dy^2);

							-- Calculate unit vector in the direction of the collision
							ax = dx / distance;
							ay = dy / distance;

							-- Project the objects' velocities onto the direction of
							-- the collision
							collisionVelX1 = obj.xVel * ax + obj.yVel * ay;
							collisionVelY1 = -obj.xVel * ay + obj.yVel * ax; 
							collisionVelX2 = checkObj.xVel * ax + checkObj.yVel * ay;
							collisionVelY2 = -checkObj.xVel * ay + checkObj.yVel * ax;

							-- Calculate the new velocities for the objects. If we want
							-- to lose some of the energy from the collision (slowing
							-- down the objects after rebounding), set the energy displacement
							-- less than 1. Code to include mass factoring has been saved
							-- for later use, if need be.
							ed = ELASTICITY;
							newVelocityX1 = collisionVelX1 + (1 + ed) * (collisionVelX2 - collisionVelX1) / 2;
							newVelocityX2 = collisionVelX2 + (1 + ed) * (collisionVelX1 - collisionVelX2) / 2;
--							newVelocityX1 = collisionVelX1 + (1 + ed) * (collisionVelX2 - collisionVelX1) / (1 + mass1 / mass2);
--							newVelocityX2 = collisionVelX2 + (1 + ed) * (collisionVelX1 - collisionVelX2) / (1 + mass1 / mass2);

							-- Calculate the new velocities by undoing the projections onto
							-- the collision axis.
							obj.xVel  = newVelocityX1 * ax - collisionVelY1 * ay;
							obj.yVel = newVelocityX1 * ay + collisionVelY1 * ax;
							checkObj.xVel  = newVelocityX2 * ax - collisionVelY2 * ay;
							checkObj.yVel = newVelocityX2 * ay + collisionVelY2 * ax;

							-- Now, accelerate time forward by dt, to allow for the collison to
							-- to happen and the objects to bounce
							obj.x = obj.x + obj.xVel  * dt;
							obj.y = obj.y + obj.yVel * dt;
							checkObj.x = checkObj.x + checkObj.xVel  * dt;
							checkObj.y = checkObj.y + checkObj.yVel * dt;

						end
					end
				end

				polyInfo.bestDist = 100;
				polyInfo.bestObj = nil;

				checkPegs = true
				pegHitTotal = 0;
				while ((checkPegs == true) and (pegHitTotal < 5))  do 

					if (self.lastPeg) then
						checkObj = self.lastPeg;
						dx = (checkObj.x - obj.x);
						dy = (checkObj.y - obj.y);
						distance = sqrt(dx^2 + dy^2);
						if (distance <= const.zoomDistance) then
							local anchorV = ""
							local anchorH = ""

							if (checkObj.y < const.boardHeight/3) then
								anchorV = "bottom";
							elseif (checkObj.y < (2 * const.boardHeight/3)) then
								anchorV = "";
							else
								anchorV = "top";
							end

							if (checkObj.x < const.boardWidth/3) then
								anchorH = "left";
							elseif (checkObj.x < (2 * const.boardWidth/3)) then
								anchorH = "";
							else
								anchorH = "right";
							end

							if (anchorH == "") and (anchorV == "") then
								anchorH = "center";
							end

							-- If we're starting the zoom, run the drums
							if not lastZoomDistance then
								lastZoomDistance = distance;
								Sound(const.SOUND_TIMPANI);
							end

							-- If we're starting to move away from the peg
							-- (which is a miss), sigh for the player.
							if (lastZoomDistance < distance) and not self.sigh then
								Sound(const.SOUND_SIGH);
								self.sigh = true;
							end
							lastZoomDistance = distance;

							local amount = max(distance, const.zoomDistance / 2)
							amount = amount / const.zoomDistance
							gameBoard:ClearAllPoints();
							gameBoard:SetPoint(anchorV .. anchorH);
							gameBoard:SetScale(1.5 - (amount - 0.5));
							GAME_SPEED = 0.1
							window.catcher:SetAlpha(0);
						else
							if (GAME_SPEED ~= 1) then
								self.sigh = nil;
								gameBoard:ClearAllPoints();
								gameBoard:SetPoint("center");
								gameBoard:SetScale(1);
								GAME_SPEED = 1
								window.catcher:SetAlpha(1);
								lastZoomDistance = nil;
							end	
						end
					end
					GAME_SPEED = DEBUG_SPEED or GAME_SPEED;

					checkPegs = false;
					
					-- Check if it hit any pegs
					checkX, checkY = GameObjectCoordLocation(obj.x, obj.y);
					if (checkX) then
						for j = checkY - 1, checkY + 1 do 
							if (j > 0) and (j <= const.boardXYSections) then
								for i = checkX - 1, checkX + 1 do 
									if (i > 0) and (i <= const.boardXYSections) then

										local collide = false;
										local bestDist = 1000;
										local checkBricks = false;

										local maxPoly;
										local px1, px2, py1, py2, segment, dxSeg, dySeg, q, centerX, centerY;
										local poly = const.polyTable;
										local bestCenterX, bestCenterY;
										local bestObj;
--													local collide = false;
										local lastX, lastY;
--													local bestDist = 1000;
										local bestVertex = 0;
										local hitSeg = 0;
										local hitAngle = 0;
										local ballAngle = 0;


										for k = 1, #gameObjectDB[j][i] do 

											-- Grab the peg to be checked and calculate the distance between
											-- the peg and the ball.
											checkObj = gameObjectDB[j][i][k];

											dx = (checkObj.x - obj.x);
											dy = (checkObj.y - obj.y);
											distance = sqrt(dx^2 + dy^2);

											-- Peg collision check
											if (checkObj.isPeg) then

												_, removed = CollisionCheck_CircleOnCircle(obj.x, obj.y, theBallRadius, checkObj.x, checkObj.y, thePegRadius, obj, checkObj, stillBall);

												if (removed) then
													break;
												end

											-- Brick collision check
											elseif (checkObj.isBrick) then

												CollisionCheck_CircleOnPolygon(obj.x, obj.y, theBallRadius, checkObj.x, checkObj.y, theBrickRadius, obj, checkObj);

											end
										end

										if (polyInfo.bestObj) then

											if (polyInfo.bestDist == -1) then
												CollisionCheck_CircleOnCircle(obj.x, obj.y, theBallRadius, polyInfo.centerX, polyInfo.centerY, 1, obj, polyInfo.bestObj, stillBall);
												polyInfo.bestObj = nil;
											else
												Collide_CircleOnPolygon(obj, polyInfo, stillBall);
											end

											checkPegs = true;
											pegHitTotal = pegHitTotal + 1;
										end
									end
									if (checkPegs == true) then
										break;
									end
								end
							end
						end
					end
				end

				-- Check for bounce on left and right walls
				if (obj.x < const.boardBoundryLeft) then
					obj.x = const.boardBoundryLeft + (const.boardBoundryLeft - obj.x);
					obj.xVel = -obj.xVel - (deltaXVel * 10);
				elseif (obj.x > const.boardBoundryRight) then
					obj.x = const.boardBoundryRight - (obj.x - const.boardBoundryRight);
					obj.xVel = -obj.xVel - (deltaXVel * 10);
				end


				-- Check if we hit our fever bumpers, if they're out.
				if (feverPegsHit >= feverPegsTotal) then
--					window.bonusBar1:Show();
--					window.bonusBar2:Show();
					if (obj.y <= 50) then
						checkY = -8;
						for index = 1, 6 do 
							checkX = self.bouncer[index];
								
							dx = (checkX - obj.x);
							dy = (checkY - obj.y);
							distance = sqrt(dx^2 + dy^2);

							-- If we are within hitting distance (the balls are closer than the sum
							-- of their radii), we have a collision.
							if (distance <= (theBallRadius + 32)) then
								Sound(const.SOUND_BUMPER);

								-- Calculate and sum the objects' components of velocity
								velocitySum1 = obj.xVel * dx / distance + obj.yVel * dy / distance;
								velocitySum2 = 0; 

								-- Calculate time of collision
	--							dt =(const.ballRadius + const.pegRadius - distance) / (velocitySum1 - velocitySum2);

								-- Reset position of the ball and peg to just before impact
								obj.x = obj.x - (obj.xVel * updateFrac) --* dt;
								obj.y = obj.y - (obj.yVel * updateFrac) -- * dt;

								-- Calculate distance between balls with reset positions
								dx = checkX - obj.x
								dy = checkY - obj.y;
								distance = sqrt(dx^2 + dy^2);

								-- Calculate unit vector in the direction of the collision
								ax = dx / distance;
								ay = dy / distance;

								-- Project the objects' velocities onto the direction of
								-- the collision (make the peg push at the opposite velocity
								-- as the ball for bouncing fun)
								collisionVelX1 = obj.xVel * ax + obj.yVel * ay;
								collisionVelY1 = -obj.xVel * ay + obj.yVel * ax; 
								collisionVelX2 = -collisionVelX1;
								collisionVelY2 = -collisionVelY1;

								-- Calculate the new velocities for the objects. If we want
								-- to lose some of the energy from the collision (slowing
								-- down the objects after rebounding), set the energy displacement
								-- less than 1. Code to include mass factoring has been saved
								-- for later use, if need be.
								ed = ELASTICITY;
								newVelocityX1 = collisionVelX1 + (1 + ed) * (collisionVelX2 - collisionVelX1) / 2;
								newVelocityX2 = collisionVelX2 + (1 + ed) * (collisionVelX1 - collisionVelX2) / 2;

								-- Calculate the new velocities by undoing the projections onto
								-- the collision axis.
								obj.xVel  = newVelocityX1 * ax - collisionVelY1 * ay;
								obj.yVel = newVelocityX1 * ay + collisionVelY1 * ax;

								-- Now, accelerate time forward by dt, to allow for the collison to
								-- to happen and the objects to bounce

								obj.x = obj.x + obj.xVel * updateFrac --* dt;
								obj.y = obj.y + obj.yVel * updateFrac -- * dt;

								checkPegs = true;
								checkBricks = true;

								break;
							end
						end
					end

				-- Check if we hit the catcher
				else
					if (obj.y < (const.boardBoundryBottom + 30)) then

						-- Fill our polygon table with the values of this brick for checking
						local maxPoly = FillPolyTable(window.catcher, const.catcherPolygon);

						local px1, px2, py1, py2, segment, dxSeg, dySeg, q, centerX, centerY;
						local pDistX, pDistY, pDist;
						local poly = const.polyTable;
						local collide = false;
						local lastX, lastY;
						local polyInfo = hitPolyInfo;
						polyInfo.bestDist = 1000;
						local bestVertex = 0;

				local hitSeg = 0;
				local hitAngle = 0;
				local ballAngle = 0;

						px2 = poly[maxPoly - 1];
						py2 = poly[maxPoly];

						for segment = 1, maxPoly, 2 do 
																
							px1 = px2
							py1 = py2;
							px2 = poly[segment];
							py2 = poly[segment+1];

							dxSeg = px2 - px1
							dySeg = py2 - py1
							
							q = ((obj.x - px1) * (dxSeg) + (obj.y - py1) * (dySeg)) / (dxSeg * dxSeg + dySeg * dySeg)
							
							if (q < 0) then
								q = 0;
							elseif (q > 1) then
								q = 1;
							end

							centerX = (1 - q) * px1 + q * px2
							centerY = (1 - q) * py1 + q * py2
							
							pDistX = obj.x - centerX
							pDistY = obj.y - centerY
							pDist = pDistX^2 + pDistY^2
		
							if (pDist) < (theBallRadius * theBallRadius) then

--------------------------------------

								if (pDist < polyInfo.bestDist) then

				--					polyInfo.bestObj = obj2;

									-- Check the corners of this line segment to see if they hit
									-- the ball instead

									if (((px1-obj.x)^2 + (py1-obj.y)^2) < 25) then
										polyInfo.bestDist = -1;
										polyInfo.centerX = px1;
										polyInfo.centerY = py1;
										collide = true;
									elseif (((px2-obj.x)^2 + (py2-obj.y)^2) < 25) then
										polyInfo.bestDist = -1;
										polyInfo.centerX = px2;
										polyInfo.centerY = py2;
										collide = true;
									
									-- If no corners were hit, we just hit the line.
									else

										polyInfo.bestDist = pDist;
										polyInfo.hitSeg = segment;
										polyInfo.hitAngle = mod(atan2(dySeg, dxSeg) + 360, 360);
										polyInfo.ballAngle = mod(atan2(obj.yVel, obj.xVel) + 360, 360);
										polyInfo.bestCenterX = centerX;
										polyInfo.bestCenterY = centerY;
										polyInfo.dxSeg = dxSeg;
										polyInfo.dySeg = dySeg;
										polyInfo.pDistX = pDistX;
										polyInfo.pDistY = pDistY;
										polyInfo.centerX = centerX;
										polyInfo.centerY = centerY;
										polyInfo.maxPoly = maxPoly;
										collide = true;
									end
								end

--------------------------------------
--[[
								bestDist = pDistX * pDistX + pDistY * pDistY;
								hitSeg = segment;
								collide = true;
								hitAngle = atan2(dySeg, dxSeg);
								if (hitAngle < 0) then
									hitAngle = hitAngle + 360;
								end
								ballAngle = atan2(obj.yVel, obj.xVel);
								if (ballAngle < 0) then
									ballAngle = ballAngle + 360;
								end
								break;
--]]
							end

						end

						if (collide == true) then

							Sound(const.SOUND_BUCKET_HIT);

							if (polyInfo.bestDist == -1) then
								CollisionCheck_CircleOnCircle(obj.x, obj.y, theBallRadius, polyInfo.centerX, polyInfo.centerY, 1, obj, polyInfo.bestObj, stillBall, true);
								polyInfo.bestObj = nil;
							else
								Collide_CircleOnPolygon(obj, polyInfo, nil, true)
							end
							obj.x = obj.x + obj.xVel * updateFrac --* dt;
							obj.y = obj.y + obj.yVel * updateFrac -- * dt;

--[[							
							-- Reset position of the ball and peg to just before impact
							obj.x = obj.x - (obj.xVel * updateFrac) --* dt;
							obj.y = obj.y - (obj.yVel * updateFrac) -- * dt;

							local normalAngle = mod(hitAngle - 90 + 360, 360);
							local reflectedAngle = mod(normalAngle + 180, 360);
							local newAngle = mod(normalAngle - (ballAngle - reflectedAngle) + 360, 360);

							velocitySum1 = sqrt(obj.xVel * obj.xVel + obj.yVel * obj.yVel) * ELASTICITY
							obj.xVel = velocitySum1 * cos(rad(newAngle));
							obj.yVel = velocitySum1 * sin(rad(newAngle));

		obj.x = centerX + cos(rad(normalAngle)) * (const.ballRadius+0.0);
		obj.y = centerY + sin(rad(normalAngle)) * (const.ballRadius+0.0);

							obj.x = obj.x + obj.xVel * updateFrac --* dt;
							obj.y = obj.y + obj.yVel * updateFrac -- * dt;

							checkPegs = true;
							pegHitTotal = pegHitTotal + 1;
--]]
							checkPegs = true;
							pegHitTotal = pegHitTotal + 1;
							break;
						end
					end
				end

				-- No bounce on the bottom, it just disappears (get's SWALLOWED!)
				if (obj.y < (const.boardBoundryBottom - 10)) then
					obj.y = -100;

--					if (abs(obj.y - const.boardBoundryBottom) < 2) and (abs(obj.yVel) < 2) then
--						obj.y = const.boardBoundryBottom;
						obj.yVel = 0;
--					else
--						obj.y = const.boardBoundryBottom;
--						obj.yVel = -(obj.yVel - (deltaYVel * 10));
--					end
				-- Bounce on the top wall...
				elseif (obj.y > const.boardBoundryTop) then
					obj.y = const.boardBoundryTop - (obj.y - const.boardBoundryTop);
					obj.yVel = -obj.yVel;
				end

				-- Adjust the velocities based upon air resistance (x velocity)
				-- If we get too little of a velocity, we need to make our object
				-- stop moving along the x axis.
				if (obj.y < theBallRadius * 2) then
					if (obj.xVel < 0) then
						obj.xVel = obj.xVel + deltaXVel;
					else
						obj.xVel = obj.xVel - deltaXVel;
					end
					if (abs(obj.xVel) < 2) then
						obj.xVel = 0;
					end
				else
					if (obj.xVel < 0) then
						obj.xVel = obj.xVel + deltaXVel;
					else
						obj.xVel = obj.xVel - deltaXVel;
					end
				end

				-- Adjust the velocities based upon gravity (y velocity)
				-- If we fall faster than gravity (ghetto terminal velocity code),
				-- set the velocity to the speed of gravity. If the velocity is
				-- too small, the object will come to a stop along the y axis
				-- (to rest on the ground, for example ... dirty code, I know)
				obj.yVel = obj.yVel + deltaYVel * obj.gravMultiplier;

--				if (obj.yVel < GRAVITY) then
--					obj.yVel = GRAVITY;
--				end
--				if (abs(obj.yVel) < 3) then
--					obj.yVel = 0;
--				end

				-- If the Y and X positions changed since the last update or they have only been the same for
				-- a few frames, update the position on screen. Otherwise, we have a ball that stopped, so we
				-- remove it...
--				sameXY = ((obj.x == obj.lastX) and (obj.y == obj.lastY)) 
				local pegInsideCatcher = ((catcher - catcherWidth) < obj.x) and ((catcher + catcherWidth) > obj.x)
				if not (obj.y <= -100) then --not ((obj.lastSame == 3) and sameXY) then
					if (sameXY) then
						obj.lastSame = (obj.lastSame or (0)) + 1;
					else
						obj.lastSame = 0;
						obj.lastX = obj.x;
						obj.lastY = obj.y;
					end

					-- Draw the ball trail during the first update check of the ball position
--					if (steppedInto == 0) then
						for ballIndex = 1, 30 do
							if (obj["trail" .. ballIndex].x > -100) then
								obj["trail" .. ballIndex]:ClearAllPoints();
								obj["trail" .. ballIndex]:SetPoint("Center", gameBoard, "Bottomleft", obj["trail" .. ballIndex].x, obj["trail" .. ballIndex].y);
								obj["trail" .. ballIndex]:Show();
							end
						end
--					end

					-- Draw the ball at the new point;
					obj:ClearAllPoints();
					obj:SetPoint("Center", gameBoard, "Bottomleft", obj.x, obj.y);

				else

					-- Remove the ball from the active ball queue and make
					-- sure we don't move the ball index (it will increment
					-- by one at the end of this loop, so we just subtract one
					-- to make sure it goes back to the proper index
					tremove(ballDB, index);
					index = index - 1;

					-- Check if we landed in the catcher
					if (feverPegsHit < feverPegsTotal) then
						if (pegInsideCatcher) then

							Sound(29);

							-- Free ball only outside of Peggle Loot mode and duel mode (?)
							if not const[const.newInfo[13]] then
								window.ballTracker:UpdateDisplay(2);
								window.catcher.freeGlowElapsed = 0;
								stats[2] = stats[2] + 1;
								self:SpawnText(window.catcher, const.locale["_FREE_BALL"], nil,nil,nil,0,40, window.catcher.x, window.catcher.y +30);
								self.freeBall = true;
							else
								stats[2] = stats[2] + 1;	
								self:SpawnText(window.catcher, string.format(const.locale["_FREE_BALL_DUEL"], NumberWithCommas((1900 + 600) * stats[2])), nil,nil,nil,0,40, window.catcher.x, window.catcher.y +30);
								bonusScore = bonusScore + (1900 + 600) * stats[2]
								bonusScoreTalents = bonusScoreTalents + (1900 + 600) * stats[2]
							end
							specialInPlay = 1;
--							StyleShotCalculate(1, window.catcher.x, window.catcher.y + 14);
--							StyleShotCalculate(4, window.catcher.x, window.catcher.y + 14);
						end

						-- Only allow free ball skill to appear if mad skill did not.
						if not StyleShotCalculate(4, window.catcher.x, window.catcher.y + 14) then
							StyleShotCalculate(1, window.catcher.x, window.catcher.y + 14);
						end
						GAME_SPEED = 1
					else
						for index = 1, 5 do 
							if (obj.x > self.bouncer[index]) and (obj.x < self.bouncer[index+1])  then
								Sound(14);
								self:SpawnParticleGen(self.bouncer[index] + ((self.bouncer[index+1] - self.bouncer[index]) / 2), 0, 1.5, 1.2, 0.03, 80, 100, 30, 40, -2, "star");
								self:SpawnParticleGen(self.bouncer[index] + ((self.bouncer[index+1] - self.bouncer[index]) / 2), 0, 1.5, 1.2, 0.015, 80, 100, 20, 40, -2, "spark")
								local feverScore;
								local feverScoreTalents

								local talentMultiplier = 0;

								-- Only let talents work outside of Peggle Loot mode
								if not const[const.newInfo[13]] then
									talentMultiplier = talentData[33 + 4];
								end

								if (stats[3] == stats[7]) then
									feverScoreTalents = floor(1000 * 100 * (1 + (talentMultiplier * 0.1)));
									feverScore = floor(1000 * 100);
								else
									feverScoreTalents = floor(self.bouncer[index+6]*10000 * (1 + (talentMultiplier * 0.1)));
									feverScore = floor(self.bouncer[index+6]*10000);
								end
								self:SpawnText(obj, NumberWithCommas(feverScoreTalents), nil, nil, nil1, 0, 80, self.bouncer[index] + ((self.bouncer[index+1] - self.bouncer[index]) / 2), 50, 0);
								totalScore = totalScore + feverScoreTalents;
								stats[5] = stats[5] + feverScoreTalents;
								stats[4] = stats[4] + feverScoreTalents - feverScore;
								currentScoreText:SetText(NumberWithCommas(totalScore));
								break
							end
						end
						GAME_SPEED = 0.3
					end

					self.sigh = nil;
					gameBoard:ClearAllPoints();
					gameBoard:SetPoint("center");
					gameBoard:SetScale(1);
					window.catcher:SetAlpha(1);
					lastZoomDistance = nil;

					-- Remove animation status of ball, insert it into the
					-- "ready" ball queue, and hide it's objects
					tinsert(animator.ballQueue, obj);
					obj.animated = nil;
					obj:Hide();

					for j = 1, 30 do 
						obj["trail" .. j]:Hide();
					end

--[[
					obj.trail1:Hide();
					obj.trail2:Hide();
					obj.trail3:Hide();
					obj.trail4:Hide();
--]]
					if (#ballDB == 0) then
						self.roundValue = NumberWithCommas(roundScoreTalents);
						self.pegsHit = 0;
						self.reclaim = true; --ReclaimPegs();
						window.feverTracker:UpdateDisplay(2);
					end

				end	
			end

			index = index + 1;

		end

		-- Update our calculation step
		steppedInto = steppedInto + updateFrac;
	
	end

	self.elapsed = 0;

end

-- /***********************************************
--   RotateTexture
--
--   Rotates the texture to the specified angle
--
--   accepts:	texture to rotate, degrees to set it to, the x origin, the y origin
--   returns:	none
--  *********************/
local function Animator_RotateTexture(self, tex, degrees, xOrigin, yOrigin)

	-- Ensure that the degrees are in range, and then grab the pre-calculated values from the tables
	if (degrees <= 0) then 
		degrees = 360 + degrees
	end

	local sinVal = self.tableSin[degrees] * 0.71;
	local cosVal = self.tableCos[degrees] * 0.71;

	-- Set the new coordinates, with the rotation coming from the origin (0.5, 0.5 ... the center of the image)
	tex:SetTexCoord(xOrigin - sinVal, yOrigin + cosVal, xOrigin + cosVal, yOrigin + sinVal, xOrigin - cosVal, yOrigin - sinVal, xOrigin + sinVal, yOrigin - cosVal);

end

local function Update_FeverBarAnimation(self, elapsed)

	if not self.active then
		return;
	end

	local turnOff = true;
	local barFlashEnd = true;
	local bar;

	-- If fever is activated, do the fever animations

	if (self.feverElapsed) then

		-- Counteract the slowed game speed
		elapsed = elapsed * 2;

		local scale = gameBoard:GetScale();
		if (scale > 1.001) then
			scale = scale - 0.01;
			if (scale < 1) then
				scale = 1;
				gameBoard:ClearAllPoints();
				gameBoard:SetPoint("center");
				window.catcher:SetAlpha(1);
			end
			gameBoard:SetScale(scale);
		end

		self.glowElapsed = self.glowElapsed + elapsed
		if (self.glowElapsed > 0.5) then
			self.glowElapsed = 0;
		end

		local i;

		-- Update the bars

		for i = 1, 25 do 
			bar = self.bar[i];
			bar.elapsed = bar.elapsed + elapsed;
			if (bar.elapsed > 0.8) then
				bar.elapsed = bar.elapsed - 0.8;
				bar:SetTexCoord(unpack(self.highlight));
				bar.on = true;
			end
			if (bar.elapsed <= 0.10) then
				bar:SetAlpha(1);
			elseif (bar.elapsed <= 0.20) then
				bar:SetAlpha(0.9);
			elseif (bar.elapsed <= 0.3) then
				bar:SetAlpha(0.8);
			else
				if (bar.on) then
					bar.on = nil;
					bar:SetTexCoord(unpack(self.normal));
					bar:SetAlpha(1);
				end	
			end
		end

		-- Update the multiplier signs

		for i = 26, 29 do 
			bar = self.bar[i];
			if (self.glowElapsed < 0.25) then
				if (i < 27) or (i > 28)  then
					bar:SetTexCoord(unpack(bar.highlight));
				else
					bar:SetTexCoord(unpack(bar.normal));
				end
			else
				if (i < 27) or (i > 28)  then
					bar:SetTexCoord(unpack(bar.normal));
				else
					bar:SetTexCoord(unpack(bar.highlight));
				end
			end
		end

	-- Otherwise, do the normal bar animations

	else

		-- Update Flashing Bars
		if (self.barFlashUpdate) then
			for i = (self.lastBar+1), feverBarsLit do 
				bar = self.bar[i];
				if (bar.elapsed) then
					barFlashEnd = nil;
					bar.elapsed = bar.elapsed + elapsed;
					if (bar.elapsed > 0.2) then
						bar.flashCount = bar.flashCount + 1;
						bar.elapsed = 0;
						if (mod(bar.flashCount, 2) == 0) then
							if (bar.flashCount >= 6) then
								bar.flashCount = nil;
								bar.elapsed = nil;
								bar:Show();
								bar:SetTexCoord(unpack(self.normal));
							else
								bar:Hide();
							end
						else
							bar:Show();
						end
					end
				end
			end

			-- If the bars stop flashing, set our current last bar, otherwise,
			-- we need to continue animating, so make sure we stay on.

			if (barFlashEnd) then
				self.lastBar = min(max(feverBarsLit, 1), 25);
				self.barFlashUpdate = nil;
--				if not animator.coin.elapsed then
--					window.ballTracker:UpdateDisplay(1);
--				end
			else
				turnOff = nil;
			end

		end

		-- Update Flashing Multipliers
		for i = 26, 29 do 
			bar = self.bar[i];
			if (bar.elapsed) then
				turnOff = nil;
				bar.elapsed = bar.elapsed + elapsed;
				if (bar.elapsed >= 0.2) then
					bar.flashCount = bar.flashCount + 1;
					bar.elapsed = 0;
					if (mod(bar.flashCount, 2) == 0) then
						if (bar.flashCount == 6) then
							bar.flashCount = nil;
							bar.elapsed = nil;
							bar:SetTexCoord(unpack(bar.highlight));
						else
							bar:SetTexCoord(unpack(bar.normal));
						end
					else
						bar:SetTexCoord(unpack(bar.highlight));
					end
				end
			end
		end

		if (turnOff) then
			self.active = nil;
		end
	end
end

local function Update_FeverDisplay(self, updateType, updateValue)

	local i;

	-- Reset display to blank
	if (updateType == 1) then

		feverBarsLit = 0;
		feverMultiplier = 1;
		self.lastBar = 0;
		self.active = nil;
		self.feverElapsed = nil;
		self.glowElapsed = nil;

		-- Reset the bars
		for i = 1, 25 do 
			self.bar[i]:Hide();
			self.bar[i].elapsed = nil;
		end

		-- Reset the x2, x3, x5, x10 displays
		for i = 26, 29 do 
			self.bar[i]:SetTexCoord(unpack(self.bar[i].normal));
			self.bar[i].elapsed = nil;
		end

	-- Un-highlight the new bars (for the next shot)
	elseif (updateType == 2) then

		if (feverPegsHit < feverPegsTotal) then
--			if (feverBarsLit < 25) then
				for i = self.lastBar + 1, feverBarsLit do
					self.bar[i].elapsed = (updateValue or 0);
					self.bar[i].flashCount = (updateValue or 0);
					self.bar[i]:Hide();
					self.barFlashUpdate = true;
				end
				self.active = true;
--			end
		end
		
	-- Add a new bar and update the fever pegs hit so far
	elseif (updateType == 3) then
		
		-- Don't let bars that don't exist light up
		if (feverBarsLit < 25) then

			-- If we're still flashing bars because the shot was quick from
			-- the previous shot, we kill 'em now...
			if (self.barFlashUpdate) then
				self.lastBar = min(max(feverBarsLit, 1), 25);
				self.barFlashUpdate = nil;
				self.active = nil;
				for i = 1, feverBarsLit do 
					bar = self.bar[i];
					bar.flashCount = nil;
					bar.elapsed = nil;
					bar:Show();
					bar:SetTexCoord(unpack(self.normal));
				end
			end

			feverBarsLit = feverBarsLit + 1;
			self.bar[feverBarsLit]:SetTexCoord(unpack(self.highlight));
			self.bar[feverBarsLit]:Show();
			if (self.nextValue[feverBarsLit]) then
				i = 25 + self.nextValue[feverBarsLit]
				self.bar[i].elapsed = 0;
				self.bar[i].flashCount = 0;
				self.bar[i]:SetTexCoord(unpack(self.bar[i].highlight));
				feverMultiplier = self.bar[i].id;
				self.active = true;
			end
		end

--		if (feverBarsLit >= 25) then
		if (feverPegsHit >= feverPegsTotal) then

			Sound(const.SOUND_ODETOJOY);
			Sound(const.SOUND_FEVER);
			local db = const.artCut;
			window.bonusBar1:Show();
			window.bonusBar2:Show();
			window.bonusBar3:Show();
			window.bonusBar4:Show();
			window.bonusBar5:Show();
			window.catcher:Hide();
			window.catcherBack:Hide();

			if (animator.lastPeg) then
				animator:SpawnParticleGen(animator.lastPeg.x, animator.lastPeg.y, 0.5, 0.3, .005, 0, 359, 1, 3, -0.05, "spark")
				animator:SpawnParticleGen(animator.lastPeg.x, animator.lastPeg.y, 0.5, 0.3, .005, 0, 359, 1, 3, -0.05, "spark")
			end
				
			window.roundPegs:SetText("");
			window.roundPegScore:SetText(""); --EXTREME FEVER");
			window.roundPegs:Show();
			window.roundPegScore:Show();
			window.fever1:Show();


			-- Setup the fever bar animation
			local j = 0;
			for i = 25, 1, -1 do 
				self.bar[i].elapsed = j * 0.125;
				j = j + 1;
				if (j == 6) then
					j = 0;
				end
				self.bar[i]:Show();
			end

			GAME_SPEED = 0.5;

			self.feverElapsed = true;
			self.glowElapsed = 0;
			self.active = true;

			animator.lastPeg = nil;

		end
	end

	self.text:SetText(25 - feverPegsHit);

end

local function BallShooter_OnUpdate(self, elapsed)

	if not self.active then
		return;
	end
	if (self.ball) then
		if (self.ball.loading) then
			self.ball.y = self.ball.y + elapsed * 900;
			self.ball:SetPoint("TopLeft", self, "BottomLeft", 22, self.ball.y);
			if (self.ball.y > (const.boardHeight - 170)) then
				self.ball:Hide();
				tinsert(self.ballQueue, self.ball);
				self.ball.loading = nil;
				self.ball = nil;
				self.active = nil;
				shooterReady = true;
				local i;
				for i = 1, 10 do
					gameBoard.trail[i]:Show();
				end
				window.shooter.ball:Show();
			end
		elseif (self.ball.adding) then
			if (self.fastAdd == true) then
				self.ball.y = self.ball.y - elapsed * 2250;
			else
				self.ball.y = self.ball.y - elapsed * 900;
			end
			self.ball:SetPoint("TopLeft", self, "BottomLeft", 22, self.ball.y);
			if (self.ball.y <= self.ball.newY) then
				Sound(const.SOUND_BALL_ADD);
				self.ball.y = self.ball.newY;
				self.ball:SetPoint("TopLeft", self, "BottomLeft", 22, self.ball.y);
				self.ball.adding = nil;
				self.ball = nil;
				self.active = nil;
				self.ballSpring:SetPoint("TopLeft", self, "BottomLeft", 18, 76 - (ballCount * 3));
				local i;
				local balls = #self.ballStack;
				for i = 1, balls do 
					self.ballStack[i].y = 74 - (balls * 3) + i * 18;
					self.ballStack[i]:SetPoint("TopLeft", self, "BottomLeft", 22, self.ballStack[i].y);
				end
				if (self.actionQueue[1]) then
					self:UpdateDisplay(tremove(self.actionQueue, 1));
				else
					self.fastAdd = nil;
				end
			end
		end
	elseif (self.springMove) then --(not window.roundPegs.elapsed) then
		self.ballSpring.y = self.ballSpring.y + (self.springMove * elapsed * 450);
		if (self.ballSpring.y < 0) then
			self.ballSpring.y = 0;
			self.springMove = 1;
		elseif (self.ballSpring.y >= self.ballSpring.newY) then
			self.springMove = nil;

			local obj = tremove(self.ballStack, #self.ballStack);
			obj.loading = true;
			self.ball = obj;
			
			local balls = #self.ballStack;
			self.ballSpring.y = 76 - (balls * 3);
--			self.ballSpring:SetPoint("TopLeft", self, "BottomLeft", 21, 76 - (balls * 3));
			local i;
			for i = 1, balls do
				self.ballStack[i].y = 74 - (balls * 3) + i * 18;
				self.ballStack[i]:SetPoint("TopLeft", self, "BottomLeft", 22, self.ballStack[i].y);
			end

		end
		self.ballSpring:SetPoint("TopLeft", self, "BottomLeft", 18, self.ballSpring.y);

	end
		

end

local function Update_BallDisplay(self, updateType, updateValue)

	local updateExtraBall, updateBallSpring

	if (updateType <= 2) and (self.active)  then
		tinsert(self.actionQueue, updateType);
		return;
	end

	-- Ball load
	if (updateType == 1) then
		if (self.ballStack[1]) then
			self.active = true;
			updateBallSpring = true;
			local balls = #self.ballStack;
			self.ballSpring.newY = 76 - ((balls - 2) * 3);
			self.ballSpring.y = 76 - ((balls-1) * 3);
			self.springMove = -1;
			if (balls < 4) then
				window.roundBalls:Hide();
				window.roundBalls:Show();
			else
				window.roundBalls:Hide();
			end
		else
			if (const[const.newInfo[11]]) then
				window.network:Send(const.commands[21], const[const.newInfo[11]] .. "+" .. DataPack(ToBase70(totalScore, 4), SeedFromName(const.name)), "WHISPER", const[const.newInfo[11] .. 4]);
				if not const[const.newInfo[12]] then
					const[const.newInfo[11]] = nil;
				end
			elseif (const.extraInfo) then
				UpdateChallengeScore(totalScore);
			end
			playerData["r" .. "ece" .. "nt"][bgIndex] = totalScore;
			if (totalScore > scoreData[bgIndex]) then
				InsertScoreData(totalScore, bgIndex, 1);
			else
				if (window.duelStatus == 3) then
					local frame = window.catagoryScreen.frames[2];

					local _, stageClears, stageFullClears = Talents_GetTotalTalentPoints();
					local playerData = ToBase70(stageClears + ((specialType * 20 + 10 + stageFullClears) * 100) + 1, 2)
					playerData = playerData .. ToBase70(totalScore, 4) .. ToBase70(const.stats[4], 4) .. ToBase70(const.stats[5], 4) .. ToBase70(const.stats[6], 4);
					local finalData = DataPack(playerData, SeedFromName(const.name));

					frame.player1.value1 = const.stats[4];
					frame.player1.value2 = const.stats[6];
					frame.player1.value3 = const.stats[5];
					frame.player1.value4 = specialType + 1;
					frame.player1.value5 = stageClears;
					frame.player1.value6 = stageFullClears;
					frame.player1.value = totalScore;
					SendAddonMessage(window.network.prefix, const.commands[6] .. "+" .. finalData, "WHISPER", frame.name2:GetText());

--					frame.result1:SetText(NumberWithCommas(totalScore));
--					frame.result1.temp = totalScore;
					frame:UpdateWinners();
					if (PeggleData.settings.closeDuelChallenge == true) then
						window.duelStatus = nil;
						window:Hide();
					end
				end
			end
			gameOver = true;
			window.summaryScreen:Show();
				
--			window.roundPegs:SetText("Game Over Text (placeholder)");
--			window.roundPegScore:SetText("(Show the end game summary also))");
--			window.roundPegs:Show();
--			window.roundPegScore:Show();
		end

	-- Ball add
	elseif (updateType == 2) then
		if (self.ballQueue[1]) then
			obj = tremove(self.ballQueue, 1);
		else
			obj = animator:CreateImage(0, 0, 18, 18, self);
			obj.texture:SetTexture(const.artPath .. "ball");
		end
		obj:Show();

		tinsert(self.ballStack, obj);
		ballCount = ballCount + 1;
		self.ballDisplay:SetText(ballCount);

		obj.y = const.boardHeight - 170;
		obj.newY = 74 - (ballCount * 3) + ballCount * 18;
		obj.adding = true;
		self.ball = obj;
		self.active = true;

		obj:SetPoint("TopLeft", self, "BottomLeft", 22, obj.y);

--		tinsert(self.ballStack, obj);
--		ballCount = ballCount + 1;
--		updateBallSpring = true

	-- Reset extra ball display
	elseif (updateType == 3) then
		self.nextValue = 25000;
		self.currentValue = 0;
		self.valueStart = 0;
		self.extraLevel = 0;
		updateExtraBall = true;
		window.range = nil;

		local r1, g1, b1, r2, g2, b2;
		r1, g1, b1 = 0, 0, 0;
		r2, g2, b2 = 0, 1, 0.7;

		self.leftbar2Top:SetVertexColor(r1, g1, b1, 0);
		self.rightbar2Top:SetVertexColor(r1, g1, b1, 0);
		self.leftbar2Middle:SetVertexColor(r1, g1, b1, 0);
		self.rightbar2Middle:SetVertexColor(r1, g1, b1, 0);
		self.leftbar2Bottom:SetVertexColor(r1, g1, b1, 0);
		self.rightbar2Bottom:SetVertexColor(r1, g1, b1, 0);

		self.leftbar1Top:SetVertexColor(r2, g2, b2, 1);
		self.rightbar1Top:SetVertexColor(r2, g2, b2, 1);
		self.leftbar1Middle:SetVertexColor(r2, g2, b2, 1);
		self.rightbar1Middle:SetVertexColor(r2, g2, b2, 1);
		self.leftbar1Bottom:SetVertexColor(r2, g2, b2, 1);
		self.rightbar1Bottom:SetVertexColor(r2, g2, b2, 1);

	-- Update extra ball display
	elseif (updateType == 4) then
		self.currentValue = updateValue;
		updateExtraBall = true;
	end

	if (updateBallSpring) then
		local balls = #self.ballStack;
		self.ballSpring.newY = 76 - (balls * 3);
		self.ballSpring.y = 76 - ((balls + 1) * 3);
		self.springMove = -1;
--		self.ballSpring:SetPoint("TopLeft", self, "BottomLeft", 21, 76 - (balls * 3));
--		local i;
--		for i = 1, balls do 
--			self.ballStack[i].y = 74 - (balls * 3) + i * 18;
--			self.ballStack[i]:SetPoint("TopLeft", self, "BottomLeft", 25, self.ballStack[i].y);
--		end
		self.ballDisplay:SetText(ballCount);
	end

	if (updateExtraBall) then
		local percentage = (self.currentValue - self.valueStart) / self.nextValue 
		if (percentage >= 1) then
			if (self.extraLevel == 1) then
				Sound(const.SOUND_EXTRABALL1);
				window.range = 1;
			elseif (self.extraLevel == 2) then
				Sound(const.SOUND_EXTRABALL2);
				window.range = 2;
			else
				Sound(const.SOUND_EXTRABALL3);
			end

			const.stats[2] = const.stats[2] + 1;
			percentage = 0;
			self.freeDisplay2:SetText(NumberWithCommas(self.nextValue));
			self.valueStart = self.nextValue;
			self.nextValue = self.nextValue + 50000; --self.nextValue * 2;
			animator.freeState = 0;
			animator.freeElapsed = 0;

			self.extraLevel = self.extraLevel + 1;

			local r1, g1, b1, r2, g2, b2;
			if (self.extraLevel == 1) then
				r1, g1, b1 = 0, 1, 0.7;
				r2, g2, b2 = 1, 0, 1;
			elseif (self.extraLevel == 2) then
				r1, g1, b1 = 1, 0, 1;
				r2, g2, b2 = 1, 1, 0;
			else 
				r1, g1, b1 = 1, 1, 0;
				r2, g2, b2 = 1, 1, 0;
			end
			
			self.leftbar2Top:SetVertexColor(r1, g1, b1, 1);
			self.rightbar2Top:SetVertexColor(r1, g1, b1, 1);
			self.leftbar2Middle:SetVertexColor(r1, g1, b1, 1);
			self.rightbar2Middle:SetVertexColor(r1, g1, b1, 1);
			self.leftbar2Bottom:SetVertexColor(r1, g1, b1, 1);
			self.rightbar2Bottom:SetVertexColor(r1, g1, b1, 1);

			self.leftbar1Top:SetVertexColor(r2, g2, b2, 1);
			self.rightbar1Top:SetVertexColor(r2, g2, b2, 1);
			self.leftbar1Middle:SetVertexColor(r2, g2, b2, 1);
			self.rightbar1Middle:SetVertexColor(r2, g2, b2, 1);
			self.leftbar1Bottom:SetVertexColor(r2, g2, b2, 1);
			self.rightbar1Bottom:SetVertexColor(r2, g2, b2, 1);

			self.ballDisplay:Hide();
			self.freeDisplay1:SetAlpha(1);
			self.freeDisplay1:Show();
			self.freeDisplayGlow:SetAlpha(1);
			self.freeDisplayGlow:Show();

			-- Free ball skils (in Peggle Loot mode)
			if (const[const.newInfo[11]]) then
				local tempSpecial = specialInPlay;
				specialInPlay = 2;
				StyleShotCalculate(1, 8, const.boardHeight - 40)
				specialInPlay = tempSpecial;

			-- extra ball!
			else
				self:UpdateDisplay(2);
			end

		end

		local barHeight = percentage * 300;
		if (barHeight < 32) then
			self.leftbar1Bottom:Hide();
			self.rightbar1Bottom:Hide();
		else
			self.leftbar1Bottom:Show();
			self.rightbar1Bottom:Show();
		end
		self.leftbar1Top:SetPoint("TopLeft", self, "BottomLeft", 12, 12 + barHeight); -- 5 - 297
	end
	
end

local function ShowGameUI(showUI)
	if (showUI == false) then
		window.gameMenu:Hide();
		window.rainbow:Hide();
		gameBoard:Hide();
		window.artBorder:Hide();
		window.summaryScreen:Hide();
		window.summaryScreen.bragScreen:Hide();
		window.charPortrait:Hide();
		animator:Hide();
		window.catagoryScreen:Show();
		window.fever1:Hide();
		window.fever2:Hide();
		window.fever3:Hide();
		window.feverPegScore:Hide();
		window.banner:Hide();
		window.banner.tex:Hide();
		if (playerData) then
			Talents_GetTalentPointInfo();
		end
		shooterReady = false;
		SetDesaturation(window.menuButton.background, true);
		window.menuButton:EnableMouse(false);
	else
		window.gameMenu:Hide();
		gameBoard:Show();
		window.artBorder:Show();
		animator:Show();
		window.catagoryScreen:Hide();
		window.charPortrait:Show();
		shooterReady = true;
		SetDesaturation(window.menuButton.background, false);
		window.menuButton:EnableMouse(true);
	end
end

local function SendChallenge(user, challenge, dataOnly)

	-- This will send everything the user needs receive a challenge.
	-- It is broken down into a few pieces (data, names, etc)
	-- and once all items are received by the user, they will respond
	-- with a "don't need" challenge event so the user knows they
	-- have it now.

	local infoList = const.newInfo;
	local send1, data1, data2;

	if not dataOnly then

		local namesList = challenge[infoList[2]];
		
		-- We don't want "+" in our data, so replace it with "���" (and replace that with "+")
		-- when it is received. This will happen for the note of the challenge

		data1 = challenge[infoList[4]];
		data2 = gsub(challenge[infoList[5]], "+", "���");
		send1 = challenge[infoList[1]] .. "+1+" .. data1 .. "+" .. data2;
		window.network:Send(const.commands[15], send1, "WHISPER", user)

		local i, j;
		local totalNames = #namesList;
		data1 = "";
		i = 1;
		while (i <= totalNames) do 
			data1 = "";
			for j = i, i + 7 do 
				if (j < totalNames) then
					if (j < (i + 7)) then
						data1 = data1 .. namesList[j] .. ",";
					else
						data1 = data1 .. namesList[j];
					end
				elseif (j == totalNames) then
					data1 = data1 .. namesList[j];
				end
			end
			send1 = challenge[infoList[1]] .. "+2+" .. data1;
			window.network:Send(const.commands[15], send1, "WHISPER", user)
			i = i + 8;
		end

		namesList = challenge[infoList[3]];
		totalNames = #namesList;
		data1 = "";
		i = 1;
		while (i <= totalNames) do 
			data1 = "";
			for j = i, i + 7 do 
				if (j < totalNames) then
					if (j < (i + 7)) then
						data1 = data1 .. namesList[j] .. ",";
					else
						data1 = data1 .. namesList[j];
					end
				elseif (j == totalNames) then
					data1 = data1 .. namesList[j];
				end
			end
			send1 = challenge[infoList[1]] .. "+3+" .. data1;
			window.network:Send(const.commands[15], send1, "WHISPER", user)
			i = i + 8;
		end

	else
		window.network:Send(const.commands[15], challenge[infoList[1]] .. "+4s+", "WHISPER", user);
	end

	-- Send the user data
	data1 = challenge[DATA];
	for i = 1, #data1, 200 do 
		send1 = challenge[infoList[1]] .. "+4+" .. sub(data1, i, min(199 + i, #data1));
		window.network:Send(const.commands[15], send1, "WHISPER", user)
	end

	-- Send our end command
	if not dataOnly then
		send1 = challenge[infoList[1]] .. "+5";
		window.network:Send(const.commands[15], send1, "WHISPER", user)
	else
		window.network:Send(const.commands[15], challenge[infoList[1]] .. "+4e+", "WHISPER", user);
	end			

end

local function BuildChallenge(levelID, totalShots, totalAttempts, timeLength, namesList, note)

	local challenge = {};
	local infoList = const.newInfo;
	local name = UnitName("player");
	local id = ToBase70(time() * 100 + floor((SeedFromName(name) % 100)), 7);

	table.sort(namesList);

	const.cCount = const.cCount + 1;

	local nameList = {};
	local noHaveList = {};
	local i;
	for i = 1, #namesList do
		tinsert(nameList, namesList[i]);
		tinsert(noHaveList, namesList[i]);
	end
	Peggle.TableRemove(noHaveList, name);

	challenge[infoList[1]] = id; 
	challenge[infoList[2]] = nameList;
	challenge[infoList[3]] = noHaveList;
	challenge[infoList[4]] = name;
	challenge[infoList[5]] = note;
	challenge[infoList[6]] = true;
	challenge[infoList[7]] = timeLength;

	local _, month, day, year = CalendarGetDate();
	local hours, minutes = GetGameTime();

	-- We can only build challenges when a game is currently not
	-- playing, so, since this is the case, load the level in
	-- question, find out how many pegs/bricks there are, then
	-- randomly distribute the red, purple, and green pieces
	-- and save this data, so we have the same start state for
	-- everyone.
	
	DeserializeLevel(levelString[levelID]);

	local totalPegs = #objects;
	local temp = {};
	local i, j;
	local pegGroup = "";
	for i = 1, totalPegs do 
		tinsert(temp, i);
	end

	-- Pick out our first 25 pegs for orange pieces,
	for i = 1, 25 do 
		j = random(1, #temp);
		pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);
	end

	local greenRadius = (thePegRadius * 9)^2;
	local greenFound;
	local lastGreen;

	-- 2 pegs for green
	for i = 1, 2 do 
		j = random(1, #temp);
		greenFound = nil;
		while (greenFound == nil) do 
			if (lastGreen) then
				if (((objects[temp[j]].x - objects[temp[lastGreen]].x)^2) + ((objects[temp[j]].y - objects[temp[lastGreen]].y)^2)) < greenRadius then
					if (#temp > 0) then
						j = random(1, #temp);
					end
				else
					greenFound = true;
				end
			else
				lastGreen = j;
				greenFound = true;
			end
		end
		pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);
	end

	-- and 1 peg for purple
	j = random(1, #temp);
	pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);

	-- Build our score data, the first two bytes each entry says if the
	-- person submitted a score or not (1000 == no score, >1000 there is a score)
	-- and inside this data the format is yyxx where xx is the level clears (01-12) + 1
	-- and yy is the full peg clears (01-12) + 10 for Bjorn, or +30 for Splork.
	-- The next 4 bytes are the scores. However, this is random data to trick people.
	-- So, for example, if the player submits a score in the future with Bjorn, 9 stage clears,
	-- and 3 full clears the first two bytes will equal:
	-- = (total stage clears) + ((total full clears + 10) * 100) + 1
	-- = (9) + ((3 + 30) * 100) + 1
	-- = 9 + 3300 + 1
	-- = 3310
	local scoreData = "";
	for i = 1, #namesList do 
		scoreData = scoreData .. ToBase70(1000, 2) .. char(random(48, 90)) .. char(random(48, 90)) .. char(random(48, 90)) .. char(random(48, 90))
	end

	-- Level ID
	-- Shot Count
	-- Time length of challenge (in hours)
	-- Current time: hour
	-- Current time: minutes
	-- Current time: day
	-- Current time: month
	-- Current time: yeah
	-- Starting peg states
	-- Scores for everyone
	local buildData = DataPack("" ..
		ToBase70(levelID, 1) .. 
		ToBase70(totalShots, 1) .. 
		ToBase70(totalAttempts, 1) .. 
		ToBase70(0, 1) .. -- usedAttempts
		ToBase70(timeLength, 2) ..
		ToBase70(hours, 1) ..
		ToBase70(minutes, 1) ..
		ToBase70(day, 1) ..
		ToBase70(month, 1) ..
		ToBase70(year, 2) ..
		pegGroup ..
		scoreData,
		SeedFromName(name));

	challenge[DATA] = buildData

	collectgarbage();

	return challenge;

end

local function GetChallenge(challenge)

	-- This function will take the data from the challenge
	-- and break it down into several pieces and return
	-- the result in the const.currentView table

	local infoList = const.newInfo;
	local view = const.currentView;
	local data = DataUnpack(challenge[DATA], SeedFromName(challenge[infoList[4]]));

	if (data) then

		-- Get the level info data
		local levelID = FromBase70(char(byte(data, 1)));
		local totalShots = FromBase70(char(byte(data, 2)));
		local totalAttempts = FromBase70(char(byte(data, 3)));
		local timeLength = FromBase70(sub(data, 5, 6));
		local hours = FromBase70(char(byte(data, 7)));
		local minutes = FromBase70(char(byte(data, 8)));
		local day = FromBase70(char(byte(data, 9)));
		local month = FromBase70(char(byte(data, 10)));
		local year = FromBase70(sub(data, 11, 12));
		local scoreData = sub(data, 69);

		-- Determine how much time is left in this challenge
		local _, thisMonth, thisDay, thisYear = CalendarGetDate();
		local thisHour, thisMinute = GetGameTime();

		-- Needs to be done... *grrr*
		
		-- View table holds the challenge information
		-- 1 - creator
		-- 2 - time left (in seconds)
		-- 3 - level ID
		-- 4 - total shots
		-- 5 - total attempts
		-- 6 - note
		-- 7 - score list
		-- 8 - details list (power used, flags obtained, all packed in)

		view[1] = challenge[infoList[4]];
		view[2] = timeLength;
		view[3] = levelID;
		view[4] = totalShots;
		view[5] = totalAttempts;
		view[6] = challenge[infoList[5]];
		
		local scoreList = view[7];
		local detailsList = view[8];
		table.wipe(scoreList);
		table.wipe(detailsList);

		-- Unpack the player details and scores
		local namesList = challenge[infoList[2]];
		local i;
		for i = 1, #namesList do
			detailsList[i] = FromBase70(sub(scoreData, (i - 1) * 6 + 1, (i - 1) * 6 + 2));
			scoreList[i] = FromBase70(sub(scoreData, (i - 1) * 6 + 3, i * 6));
			if (detailsList[i] == 1000) then
				scoreList[i] = -1;
			end
		end

	end

	return true;

end

local function Net_ChannelNameFilter(self, event, message, ...)

	message = gsub(message, "%*", "");

	local grabbedNames = {strsplit(",", message)};
	local content = window.catagoryScreen.frames[3].content2;
	local namesList = content.inviteList;
	local i, name;
	for i = 1, #grabbedNames do 
		name = strtrim(grabbedNames[i]);
		Peggle.TableInsertOnce(namesList, name);
	end
	table.sort(namesList);
	content.nameGrabber.elapsed = 0;

	return true

end

local function Net_ChatFilter(self, event, message, ...)

	local name = string.match(message, const.filterText);

-- Part #2 of 4 for "Player not online" message fix
	if (const.last) then
		local checkName = string.lower(name);
		if (checkName == const.last) then
			const.last = nil;
			return;
		end
	end
	const.last = nil;
-- End fix

	if (name) then
--		name = string.lower(name);
		if (const.onlineList[name]) then
			const.onlineList[name] = nil;
			const.offlineList[name] = true;

			-- If this user was a server, we need to do some fun stuff...
			local i, challenge;
			local challengeGroup = playerChallenges;
			for i = 1, #challengeGroup do 

				challenge = challengeGroup[i];

				-- If our server went offline, we need to pick a
				-- new server and inform everyone of the pick
				if (challenge.serverName == name) then

					local j;
					local nameList = challenge.names;
					local msg = const.commands[12] .. "+" .. challenge.id .. "+";

					challenge.serverName = nil;

					for j = 1, #nameList do 
						name = nameList[j];
						if (const.onlineList[name] == 2) then
							if not challenge.serverName then
--								challenge.serverName = name;
								name = gsub(name, "^%l", string.upper);
								msg = msg .. name;
								break;
							end
--							SendAddonMessage(const.addonName, msg, "WHISPER", name);
						end
					end
					
					if not challenge.serverName then
						for j = 1, #nameList do 
							name = nameList[j];
							if (const.onlineList[name] == 2) then
								name = gsub(name, "^%l", string.upper);
								SendAddonMessage(const.addonName, msg, "WHISPER", name);
							end
						end
					end

				end
			end
			--printd(name .. " IS OFFLINE!");
		end
		return event, true, ...
	end

end;

local function Net_GetOnlineList()

	-- Prep for online gathering. We keep track of everyone we ping
	-- as well as if they are online or offline. The purpose of the
	-- online list is to send challenge data only to online people
	-- and if they go offline, we add them to the offline list. Likewise,
	-- when someone comes online and pings the challenge list, they will
	-- let people know that they are online, updating the online/offline
	-- list as well. This is a tricky thing that is odd to set up...

	local pingedList = const.sentList;
	local onlineList = const.onlineList;
	local offlineList = const.offlineList;

	table.wipe(pingedList);
	table.wipe(offlineList);
	table.wipe(onlineList);

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Net_ChatFilter)

--	PeggleData.challenges = {};
--	PeggleData.challenges[1] = {["names"] = {"Raikah","Saurio"}, ["id"] = "ABC", ["namesWithoutChallenge"] = {"Saurio"}};
--	Peggle.TablePack(PeggleData.challenges[1].names, strsplit(",", "Raikah,a3aaaaaaaaa123,a4aaaaaaaaa123"));
--
	local challengeIndex, challenge, nameIndex, name, nameList;
	local challengeGroup = playerChallenges

	for challengeIndex = 1, #challengeGroup do 
		
		challenge = challengeGroup[challengeIndex]
		challenge.serverName = nil;

		-- Build the name list
		nameList = challenge.names;

		-- Now, for each name, make sure we add it onto the pinged list if
		-- it's not already and queue it up for online checks.
		for nameIndex = 1, #nameList do 
			name = gsub(nameList[nameIndex], "^%l", string.upper);
			if not pingedList[name] then
				pingedList[name] = true;
				onlineList[name] = 1;
			end
		end

	end

	-- Now, all names from all challenges are loaded into the ping list.
	-- Turn our player checker on and let it flush itself out and get
	-- our data updated
	pinger = window.network.pinger;
	pinger.elapsed = 0;
	pinger.lastIndex = -1;
	pinger:Show();
--]]	
end

local function Net_OnLogIn(state)
--	PeggleData.challenges = {};
--	PeggleData.challenges[1] = BuildChallenge(1, 12, 48, {"Saurio", "Raikah"}, "This is a test!");
	local pinger = window.network.pinger;

	-- Obtain the list of online players
	if not state then

		-- Reset all challenges so the server name and updating flags are
		-- removed
		local i, j, timeLength, timeSoFar, hour, minute, day, month, year;
		local challengeGroup = playerChallenges
		j = 1;
		for i = 1, #challengeGroup do 
			challengeGroup[j].serverName = nil;
			challengeGroup[j].updating = nil;
			challengeGroup[j].new = nil;
			challengeGroup[j].dirty = nil;

			-- If the challenge needs to be removed, remove it
			if (challengeGroup[j].removed == true) or (challengeGroup[j][DATA] == nil) or (challengeGroup[j][DATA] == "") then
				tremove(challengeGroup, j);
			else
				timeLength = FromBase70(sub(challengeGroup[j][DATA], 3 + 5, 3 + 6));
				hour = FromBase70(sub(challengeGroup[j][DATA], 3 + 7, 3 + 7));
				minute = FromBase70(sub(challengeGroup[j][DATA], 3 + 8, 3 + 8));
				day = FromBase70(sub(challengeGroup[j][DATA], 3 + 9, 3 + 9));
				month = FromBase70(sub(challengeGroup[j][DATA], 3 + 10, 3 + 10));
				year = FromBase70(sub(challengeGroup[j][DATA], 3 + 11, 3 + 12));
				timeSoFar = Peggle.MinuteDifference(hour, minute, day, month, year);

				-- If the time so far is past the challenge length, mark it as ended
				-- so that we have the challenge finished;
				if (timeSoFar >= timeLength) then
					challengeGroup[j].ended = true;
					timeSoFar = timeSoFar - timeLength;
				end

				if (challengeGroup[j].creator == const.name) and not challengeGroup[j].ended then
					const.cCount = const.cCount + 1;
				end

				-- If the time so far is part the challenge length AGAIN, we
				-- just delete it since it's past the "challenge ended" decay
				-- time
				if (timeSoFar >= timeLength) then
					tremove(challengeGroup, j);
				
-- Challenge length 40
-- Time since challenge started: 43;
-- Time so far = 43;
-- Challeng ended, so time so far = 3;
-- Elapsed = challengeLength - time so far;

				-- Otherwise, we populate the elapsed timed to show the total
				-- minutes left till the challenge ends or the challenge is
				-- removed
				else
					challengeGroup[j].elapsed = timeLength - timeSoFar;
					j = j + 1;
				end
			end
		end

		pinger.command = const.commands[8] -- .. "+" .. const.ping; -- "ping"
		pinger.data = "";
		pinger.state = 0;
		pinger.challengeIndex = 0;
		Net_GetOnlineList();

	-- Otherwise, continue with the state we're in
	else 

		local challengeIndex, challenge, nameIndex, name, nameList, i, found, namesWithoutChallenge;
		local pingedList = const.sentList;
		local onlineList = const.onlineList;
		local offlineList = const.offlineList;
		local challengeGroup = playerChallenges

--[[
	"ccs",	-- [10]	: Challenge - Check for server
	"csu",  -- [11]	: Challenge - Server is unknown (not yet established)
	"csn",	-- [12] : Challenge - Server Name is ... ______
	"cqr",	-- [13] : Challenge - Query Request (get scores from player)
	"cqa",	-- [14] : Challenge - Query Answer (give scores to server)
	"cgc",  -- [15] : Challenge - Give challenge to player
	"cnc",  -- [16] : Challenge - Need challenge? 
	"cdn",  -- [17] : Challenge - Don't need challenge (has it)
	"cdh",  -- [18] : Challenge - Don't have challenge (needs it like water)
--]]

		-- State #1: We're going through all challenges and finding out the server name
		-- We do this first so a server can be set up before challenges are given out
		-- to people who don't have the challenge yet. That way, when they get the
		-- challenge, they will also have the server name to go with it and be able
		-- to start updating their data.

		if (state == 1) then

			-- Clear our ping list, we're gonna hit it up again.
			table.wipe(pingedList);

			-- If we're already in this state and checking for servers,
			-- update the challenge we just checked to have the proper
			-- server name if it doesn't exist yet.
			if (pinger.challengeIndex > 0) then

				challenge = challengeGroup[pinger.challengeIndex]
				
				if not challenge.serverName then
--printd("find Server");
					nameList = challenge.names;
					namesWithoutChallenge = challenge.namesWithoutChallenge
					Peggle.TableRemove(namesWithoutChallenge, const.name);
					table.sort(nameList);

					-- The first person who was online in the sorted list
					-- will become the server, if they have the challenge
					for nameIndex = 1, #nameList do
						name = nameList[nameIndex];
						if (onlineList[name] == 2) then
							found = Peggle.TableFind(namesWithoutChallenge, name);
							if not found then
								challenge.serverName = name
--printd(name .. " is server");
								-- If we're the server, turn us on.
								if (name == const.name) then
									local i;
									local server = window.network.server;
									local challengeFound;
									for i = 1, #server.tracking do 
										if (challenge == server.tracking[i]) then
											challengeFound = true;
											break;
										end
									end
									if not challengeFound then
										challenge[const.newInfo[14]] = true;
										tinsert(server.tracking, challenge);
										tinsert(server.list, {{}, {}, {}, nil, nil});
										server:Populate(#server.list);
										if not server:IsShown() then
											server.currentID = 1; --#server.tracking;
											server.currentNode = 0;
										end
										server:Show();
									end
								end
								break;
							end
						end
					end
				end
			end

			pinger.challengeIndex = pinger.challengeIndex + 1;

			-- If we have a challenge to check, continue
			if (pinger.challengeIndex <= #challengeGroup) then

				challenge = challengeGroup[pinger.challengeIndex]
				challenge.serverName = nil;
				pinger.command = const.commands[10]; -- "ccs"
				pinger.data = challenge.id

				-- Grab the list of people for the challenge
				nameList = challenge.names;
				namesWithoutChallenge = challenge.namesWithoutChallenge

				table.sort(nameList);

				-- Now, for each name, make sure we add it onto the pinged list if
				-- it's not already and queue it up for online checks. We only
				-- do this for people who have the addon turned on, hense the
				-- online check for status == 2. Also, we only do this for people
				-- who have the challenge. When we start passing the challenge
				-- on to players who don't, they will receive the server at that
				-- time
				for nameIndex = 1, #nameList do 
					name = gsub(nameList[nameIndex], "^%l", string.upper);
					if (onlineList[name] == 2) then
						found = Peggle.TableFind(namesWithoutChallenge, name);
						if not found then
							pingedList[name] = true;
						end
					end
				end

				pinger.elapsed = 0;
				pinger.lastIndex = -1;
				pinger:Show();
				return;

			-- If we don't have anymore challenges left to query, we're done with
			-- the server checking. Now, start up state 2 (handing out challenges).
			else
				pinger.state = 2;
				pinger.challengeIndex = 0;
				state = 2;
			end
		end

		-- State #2: We're going through all challenges and check if people need
		-- the challenge. We do this because we don't know if the other player
		-- has the challenge yet, until we check ourselves.
	
		if (state == 2) then

			-- Clear our ping list, we're gonna hit it up again.
			table.wipe(pingedList);

			pinger.challengeIndex = pinger.challengeIndex + 1;

			-- If we have a challenge to check, continue
			if (pinger.challengeIndex <= #challengeGroup) then

				challenge = challengeGroup[pinger.challengeIndex]

				if not challenge.ended then
					pinger.command = const.commands[16]; -- "cnc"
					pinger.data = challenge.id;

					-- Grab the list of people who need the challenge
					nameList = challenge.namesWithoutChallenge

					-- Now, for each name, make sure we add it onto the pinged list if
					-- it's not already and queue it up for challenge checks. We only
					-- do this for people who have the addon turned on, hense the
					-- online check for status == 2. 
					for nameIndex = 1, #nameList do 
						name = gsub(nameList[nameIndex], "^%l", string.upper);
						if (onlineList[name] == 2) then
							pingedList[name] = true;
						end
					end

					pinger.elapsed = 0;
					pinger.lastIndex = -1;
					pinger:Show();
					return;
				end

			-- If we don't have anymore challenges left to query, we're done with
			-- the server checking. Now, start up with state 3 (updating the server
			-- with our current result).
			else
				pinger.state = 3;
				pinger.challengeIndex = 0;
				state = 3;
			end

		end
	end
		
	-- If server was found, update with your score.
end

local function CreateBallDisplay()

	local artBorder = window.artBorder;
	local db = const.artCut;

	-- Ball tracking area
	local container = CreateFrame("ScrollFrame", "", artBorder);
	container:SetWidth(64);
	container:SetHeight(300);
	container:SetPoint("BottomLeft", window.leftBorder, "BottomLeft", -8, 56);

	local contents = CreateFrame("Frame", "", window);
	contents:SetWidth(64);
	contents:SetHeight(300);
	contents:SetPoint("BottomLeft");
	container:SetScrollChild(contents);
	container:SetVerticalScroll(0);

	local text = Peggle:CreateCaption(0,0,"9", artBorder, 25, 0, 1, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center", window.leftBorder, "TopLeft", 36, -36); -- 45, -64);
	contents.ballDisplay = text;

	local artSeg = artBorder:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("Center", artBorder, "TopLeft", 43, -62);
	artSeg:SetWidth(128);
	artSeg:SetHeight(128);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(db["glow"]));
	artSeg:SetAlpha(1);
	artSeg:SetVertexColor(0,1,0);
	artSeg:Hide();
	contents.freeDisplayGlow = artSeg;

	local seg = db["extraBallBottomCover"];
	artSeg = contents:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft");
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));

	seg = db["extraBallTopCover"];
	artSeg = contents:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", 16, 346 - 56);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));

	-- left bar (foreground and background, with bar 2 being
	-- used, maybe, if we are doing a second free ball?)

	seg = db["extraBallBarTop"];

	artSeg = container:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("TopLeft", contents, "BottomLeft", 12, 12);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetVertexColor(0,1,0.7, 0);
	contents.leftbar2Top = artSeg;

	artSeg = container:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Top", contents.leftbar2Top, "Top");
	artSeg:SetPoint("Left", contents, "Left", 38, 0);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(seg[2], seg[1], seg[3], seg[4]);
	artSeg:SetVertexColor(0,1,0.7, 0);
	contents.rightbar2Top = artSeg;

	artSeg = contents:CreateTexture(nil, "BACKGROUND");
	artSeg:SetPoint("TopLeft", contents, "BottomLeft", 12, 12);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetVertexColor(0,1,0.7);
	contents.leftbar1Top = artSeg;

	artSeg = contents:CreateTexture(nil, "BACKGROUND");
	artSeg:SetPoint("Top", contents.leftbar1Top, "Top");
	artSeg:SetPoint("Left", contents, "Left", 38, 0);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(seg[2], seg[1], seg[3], seg[4]);
	artSeg:SetVertexColor(0,1,0.7);
	contents.rightbar1Top = artSeg;

	seg = db["extraBallBar"];

	artSeg = container:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("TopRight", contents.leftbar2Top, "BottomRight");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 12, 12);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetVertexColor(0,1,0.7, 0);
	contents.leftbar2Middle = artSeg;

	artSeg = container:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("TopRight", contents.rightbar2Top, "BottomRight");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 38, 12);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(seg[2], seg[1], seg[3], seg[4]);
	artSeg:SetVertexColor(0,1,0.7, 0);
	contents.rightbar2Middle = artSeg;

	artSeg = contents:CreateTexture(nil, "BACKGROUND");
	artSeg:SetPoint("TopRight", contents.leftbar1Top, "BottomRight");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 12, 12);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetVertexColor(0,1,0.7);
	contents.leftbar1Middle = artSeg;

	artSeg = contents:CreateTexture(nil, "BACKGROUND");
	artSeg:SetPoint("Top", contents.leftbar1Top, "Bottom");
	artSeg:SetPoint("Right", contents.rightbar1Top, "Right");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 38, 12);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(seg[2], seg[1], seg[3], seg[4]);
	artSeg:SetVertexColor(0,1,0.7);
	contents.rightbar1Middle = artSeg;

	seg = db["extraBallBarBot"];

	artSeg = container:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 12, 12);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetVertexColor(0,1,0.7, 0);
	contents.leftbar2Bottom = artSeg;

	artSeg = container:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 38, 12);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(seg[2], seg[1], seg[3], seg[4]);
	artSeg:SetVertexColor(0,1,0.7, 0);
	contents.rightbar2Bottom = artSeg;

	artSeg = contents:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 12, 12);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg:SetVertexColor(0,1,0.7);
	contents.leftbar1Bottom = artSeg;

	artSeg = contents:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("BottomLeft", contents, "BottomLeft", 38, 12);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(seg[2], seg[1], seg[3], seg[4]);
	artSeg:SetVertexColor(0,1,0.7);
	contents.rightbar1Bottom = artSeg;

	contents.leftbar1Top:SetPoint("TopLeft", contents, "BottomLeft", 12, 297);
	contents.leftbar2Top:SetPoint("TopLeft", contents, "BottomLeft", 12, 297);

	text = Peggle:CreateCaption(0,0,const.locale["FREE_BALL2"],artBorder, 18, 0, 1, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center", artBorder, "TopLeft", 46, -62);
	contents.freeDisplay1 = text;
	text:Hide();

	text = Peggle:CreateCaption(0,0,"25,000",artBorder, 12, 0, 1, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center", artBorder, "TopLeft", 46, -62);
	contents.freeDisplay2 = text;
	text:Hide();

	window.ballTracker = contents;
	contents.extraLevel = 0;

	contents.UpdateDisplay = Update_BallDisplay;
	contents.ballQueue = {};
	contents.ballStack = {};
	contents.actionQueue = {};
	contents:SetScript("OnUpdate", BallShooter_OnUpdate);

	seg = db["ballLoader"];

	artSeg = contents:CreateTexture(nil, "BACKGROUND");
	artSeg:SetPoint("TopLeft", contents, "BottomLeft", 17, 76);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	contents.ballSpring = artSeg;
	
end

local function CreateFeverTracker()

	local artBorder = window.artBorder;
	local db = const.artCut;

	-- Fever tracking area
	local container = CreateFrame("Frame", "", artBorder);
	container:SetWidth(48);
	container:SetHeight(300);
	container:SetPoint("BottomRight", window.rightBorder3, "BottomRight", -8, 54);

	local seg = db["feverBottomCover"];
	local artSeg = container:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", 2, 0);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));

	seg = db["feverTopCover"];
	artSeg = container:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", 2, 293);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));

	local text = Peggle:CreateCaption(0,0,"25", artBorder, 25, 1, 0.69, 0, true)
--	local text = Peggle:CreateCaption(0,0,"25", artBorder, 22, 1, 1, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center", window.rightBorder1, "TopRight", -48, -36); -- -43, -63);
--	text:SetPoint("Center", artBorder, "TopRight", -44, -57);
	container.text = text;

--	text = Peggle:CreateCaption(0,0,const.locale["ORANGE_PEGS"], artBorder, 9, 1, 1, 0, true, nil, "")
--	text:ClearAllPoints();
--	text:SetPoint("Center", artBorder, "TopRight", -44, -76);

	container.bar = {};
	seg = db["feverBar"];
	local barHeight = floor((seg[4] - seg[3]) * 512 + 0.5) -- - 4.25;
	local i;
	for i = 0, 24 do
		artSeg = container:CreateTexture(nil, "ARTWORK");
		artSeg:SetPoint("BottomLeft", 3, i * barHeight + 5);
		artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
		artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
		artSeg:SetTexture(const.artPath .. "board1");
		artSeg:SetTexCoord(unpack(seg));
		tinsert(container.bar, artSeg);
	end
	container.normal = const.artCut["feverBar"];
	container.highlight = const.artCut["feverBarHighlight"];

	seg = db["fever2x"];
	artSeg = container:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", -5, 512 - 336 - 62);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg.normal = db["fever2x"];
	artSeg.highlight = db["fever2xHighlight"];
	tinsert(container.bar, artSeg);
	artSeg.id = 2;

	seg = db["fever3x"];
	artSeg = container:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", -5, 512 - 277 - 61);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg.normal = db["fever3x"];
	artSeg.highlight = db["fever3xHighlight"];
	tinsert(container.bar, artSeg);
	artSeg.id = 3;

	seg = db["fever5x"];
	artSeg = container:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", -5, 512 - 229 - 60);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg.normal = db["fever5x"];
	artSeg.highlight = db["fever5xHighlight"];
	tinsert(container.bar, artSeg);
	artSeg.id = 5;

	seg = db["fever10x"];
	artSeg = container:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("BottomLeft", -5, 512 - 194 - 59);
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	artSeg.normal = db["fever10x"];
	artSeg.highlight = db["fever10xHighlight"];
	tinsert(container.bar, artSeg);
	artSeg.id = 10;

	container.nextValue = {
		[10] = 1,
		[15] = 2,
		[19] = 3,
		[22] = 4,
	};

	container.UpdateDisplay = Update_FeverDisplay;
	container.Update = Update_FeverBarAnimation;

	window.feverTracker = container;
--	container.feverElapsed = true;
--	container.glowElapsed = 0;
--	container.active = true;
end

local function CreateSummaryScreen()

	local obj = CreateFrame("Frame", "", window.artBorder);
	obj:SetPoint("Center", gameBoard, "Center", 0, -20)
	obj:SetWidth(380);
	obj:SetHeight(260);
	obj:EnableMouse(true);
	obj:SetFrameLevel(obj:GetFrameLevel() + 3);
	obj.noPublishHeight = 260;
	obj.publishHeight = 260 + 40 + 4;

	obj:SetMovable(true);
	obj:RegisterForDrag("LeftButton");
	obj:SetScript("OnDragStart", window:GetScript("OnDragStart"));
	obj:SetScript("OnDragStop", window:GetScript("OnDragStop"));

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.edgeFile = const.artPath	 .. "windowBorder"; 
	windowBackdrop.bgFile = const.artPath .. "windowBackground";
	windowBackdrop.edgeSize = 32;
	windowBackdrop.tileSize = 64;
	windowBackdrop.insets.right = 8;
	windowBackdrop.insets.left = 8;
	windowBackdrop.insets.top = 8;
	windowBackdrop.insets.bottom = 8;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.7,0.7,0.7, 1);

	local frame = obj;
	obj:Hide();
	window.summaryScreen = obj;

	obj:SetScript("OnShow", function (self)

		window.fever1:Hide();
		window.fever2:Hide();
		window.fever3:Hide();
		window.feverPegScore:Hide();

		self:SetPoint("Center", gameBoard, "Center", 0, -20)
		-- Determine if we failed, beat the level, or cleared it 100%

		animator.temp1 = nil;
		animator.temp2 = nil;
		window.rainbow:Hide();

		local flag = 0;
		if (#animator.animationStack == 0) then
			flag = 2;
		elseif (feverPegsHit == (20 + 5)) then
			flag = 1;
		end

		-- Duels
		if (window.duelStatus) then
			flag = 3
			self.publish:Hide();
			self:SetHeight(self.noPublishHeight);

		-- Challenges
		elseif (const.extraInfo) then
			flag = 4
			self.publish:Show();
			self:SetHeight(self.publishHeight);

		-- Peggle Loot
		elseif (const[const.newInfo[13]]) then
			flag = 5
			self.publish:Show();
			self:SetHeight(self.publishHeight);

		-- Normal mode
		else
			self.publish:Show();
			self:SetHeight(self.publishHeight);
		end				

		local percentage = floor(const.stats[3] / const.stats[7] * 100)
		self.title:SetText(const.locale["_SUMMARY_TITLE" .. flag]);
		self.best:SetFormattedText(self.best.caption1, NumberWithCommas(scoreData[bgIndex]))
		self.current:SetFormattedText(self.current.caption1, NumberWithCommas(totalScore))
		self.stat1:SetText(const.stats[1]);
		self.stat2:SetText(const.stats[2]);
		self.stat3:SetFormattedText("%d%%", percentage);
		self.stat4:SetText(NumberWithCommas(const.stats[4]));
		self.stat5:SetText(NumberWithCommas(const.stats[5]));
		self.stat6:SetText(NumberWithCommas(const.stats[6]));
		self.publishInfo = NumberWithCommas(totalScore);
	end);

	local text = Peggle:CreateCaption(0,0, "", obj, 25, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -36);
	obj.title = text;

	local x = 20;
	local y = 74;

	text = Peggle:CreateCaption(x,y+24, const.locale["SUMMARY_SCORE_YOURS"], obj, 23, 1, 0.82, 0, 1, nil)
--	text = Peggle:CreateCaption(x,y, "", obj, 22, 1, 1, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Top", 0, -y + 2);
	text.caption1 = text:GetText();
	obj.current = text;

	y = y + 32 - 2;

	local size = 17;

	text = Peggle:CreateCaption(x,y, const.locale["SUMMARY_STAT1"], obj, size, 1, 0.82, 0, nil, nil)
	text = Peggle:CreateCaption(x,y, "", obj, size, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topright", obj, "Topleft", x + 144, -y);
	obj.stat1 = text;

	text = Peggle:CreateCaption(x,y+((size + 1) * 1 ), const.locale["SUMMARY_STAT2"], obj, size, 1, 0.82, 0, nil, nil)
	text = Peggle:CreateCaption(x,y, "", obj, size, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topright", obj, "Topleft", x + 144, -y - ((size + 1) * 1 ));
	obj.stat2 = text;

	text = Peggle:CreateCaption(x,y+((size + 1) * 2 ), const.locale["SUMMARY_STAT3"], obj, size, 1, 0.82, 0, nil, nil)
	text = Peggle:CreateCaption(x,y, "", obj, size, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topright", obj, "Topleft", x + 144, -y - ((size + 1) * 2 ));
	obj.stat3 = text;

	x = 170
	text = Peggle:CreateCaption(x,y, const.locale["SUMMARY_STAT5"], obj, size, 1, 0.82, 0, nil, nil)
	text = Peggle:CreateCaption(x,y, "", obj, size, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topright", obj, "Topleft", x + 190, -y);
	obj.stat5 = text;

	text = Peggle:CreateCaption(x,y+((size + 1) * 1 ), const.locale["SUMMARY_STAT6"], obj, size, 1, 0.82, 0, nil, nil)
	text = Peggle:CreateCaption(x,y, "", obj, size, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topright", obj, "Topleft", x + 190, -y - ((size + 1) * 1 ));
	obj.stat6 = text;

	text = Peggle:CreateCaption(x,y+((size + 1) * 2 ), const.locale["SUMMARY_STAT4"], obj, size, 1, 0.82, 0, nil, nil)
	text = Peggle:CreateCaption(x,y, "", obj, size, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topright", obj, "Topleft", x + 190, -y - ((size + 1) * 2 ));
	obj.stat4 = text;

	text = Peggle:CreateCaption(x,y, const.locale["SUMMARY_SCORE_BEST"], obj, size, 1, 0.82, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Top", 0, -y - 66);
	text.caption1 = text:GetText();
	obj.best = text;

	obj = CreateButton(0, 0, 40, "buttonPublish", true, "sumPublish", frame, function (self)
--		self:Hide();
--		self:GetParent():SetHeight(self:GetParent().noPublishHeight);
--		SendChatMessage(string.format(const.locale["_PUBLISH_SCORE"], UnitName("player"), self:GetParent().publishInfo, const.locale["_LEVEL_NAME" .. bgIndex]), const.channels[PeggleData.settings.defaultPublish]);
--		self.publishInfo = nil;
		window.summaryScreen.publishDuel = nil;
		window.summaryScreen.bragScreen:SetParent(window.summaryScreen);
		window.summaryScreen.bragScreen:SetFrameLevel(window.summaryScreen:GetFrameLevel() + 10);
		window.summaryScreen.bragScreen:Show();
--		self:GetParent():Hide();
	end, nil, true)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", -1, 16+44);
	frame.publish = obj;

	obj = CreateButton(0, 0, 40, "buttonOkay", nil, "sumOkay", frame, function (self)
		self.publishInfo = nil;
		ShowGameUI(false);
		if (PeggleData.settings.closePeggleLoot == true) then
			window:Hide();
		end
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", 0, 16);
	obj:Show();


	-- Brag window creation
	-- ==================================================

	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Bottom", 0, 10)
	obj:SetWidth(340);
	obj:SetHeight(200);
	obj:EnableMouse(true);
	obj:SetFrameLevel(obj:GetFrameLevel() + 3);

	frame.bragScreen = obj;
	obj:Hide();
--[[
	obj:SetScript("OnShow", function (self)
		if (window.summaryScreen.publishDuel) then
			window.summaryScreen.bragScreen:SetParent(window.catagoryScreen.frames[2]);
			window.summaryScreen.bragScreen:SetFrameLevel(window.catagoryScreen.frames[2]:GetFrameLevel() + 10);
		else
			window.summaryScreen.bragScreen:SetParent(window.summaryScreen);
			window.summaryScreen.bragScreen:SetFrameLevel(window.summaryScreen:GetFrameLevel() + 10);
		end
	end);
--]]
	obj:SetScript("OnHide", function (self)
		window.summaryScreen.publishDuel = nil;
		self:SetParent(window.summaryScreen);
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
	end);

--	obj:SetMovable(true);
--	obj:RegisterForDrag("LeftButton");
--	obj:SetScript("OnDragStart", window:GetScript("OnDragStart"));
--	obj:SetScript("OnDragStop", window:GetScript("OnDragStop"));

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.7,0.7,0.7, 1);
	
		obj.serverChannels = {};
		obj.channelNames = {};

		obj.refreshChannels = function (self, ...)
			table.wipe(self.serverChannels);
			local i;
			for i = 1, #(...) do 
				tinsert(self.serverChannels, (select(i, ...)));
			end
			table.wipe(self.channelNames);
			local name, j
			for i = 1, 15 do 
				_, name = GetChannelName(i);
				if (name) then
					for j = 1, #self.serverChannels do 
						if (string.find(name, self.serverChannels[j])) then
							name = nil;
							break;
						end
					end
					if (name) then
						tinsert(self.channelNames, name)
					end
				end
			end
		end

		text = Peggle:CreateCaption(0,0, const.locale["BRAG"], obj, size, 1, 0.82, 0, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", 0, -36);
		text:SetWidth(290);

		local drop = CreateDropdown(40, 72, 240, "defaultPublish", "", nil, obj, nil); --const.locale["OPT_PUBLISH"], nil, obj, nil)
		drop.publish = true;

		local button = CreateButton(0, 0, 40, "buttonPublish", true, "bragPublish", obj, function (self)

			local parent = window.summaryScreen;

			local channelID = GetChannelName(PeggleData.settings.defaultPublish);
			local chatMessage;

			if not parent.publishDuel then
				parent:SetHeight(parent.noPublishHeight);
				chatMessage = string.format(const.locale["_PUBLISH_SCORE"], UnitName("player"), parent.publishInfo, const.locale["_LEVEL_NAME" .. bgIndex]);
			else
				chatMessage = parent.publishInfo
			end

			if (channelID > 0) then
				SendChatMessage(chatMessage, "CHANNEL", nil, channelID);
			else
				SendChatMessage(chatMessage, PeggleData.settings.defaultPublish);
			end

			parent.bragScreen:Hide();
			if not parent.publishDuel then
				parent:Show();
			end
			parent.publish:Hide();
			window.catagoryScreen.frames[2].publish:Hide();

			parent.publishDuel = nil;
			parent.publishInfo = nil;

		end, nil, true)
		button:ClearAllPoints();
		button:SetPoint("Bottomleft", 16, 16);

		button = CreateButton(0, 0, 40, "buttonBack", nil, "bragBack", obj, function (self)
			self:GetParent():Hide();
			window.summaryScreen:Show();
		end, nil, true)
		button:ClearAllPoints();
		button:SetPoint("Bottomright", -16, 16);

end

local function CreateGameMenu()
	
	local obj = CreateFrame("Frame", "", window.artBorder);
	obj:SetPoint("Center", gameBoard, "Center", 0, -20)
	obj:SetWidth(240);
	obj:SetHeight(214);
	obj:EnableMouse(true);
	obj:SetFrameLevel(obj:GetFrameLevel() + 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;
	windowBackdrop.bgFile = const.artPath .. "windowBackground";

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.7,0.7,0.7, 1);
	obj:SetBackdropBorderColor(1,0.8,0.45);
	local frame = obj;
	obj:Hide();
	window.gameMenu = obj;

	obj:SetScript("OnShow", function (self)
		animator:Hide();
		if (const[const.newInfo[13]]) or (const.extraInfo) or ((window.duelStatus == 3) and window.catagoryScreen.frames[2].player1.value == -1) then
			SetDesaturation(self.restart.background, true);
			self.restart:EnableMouse(false);
		else
			SetDesaturation(self.restart.background, false);
			self.restart:EnableMouse(true);
		end	
	end);

	obj:SetScript("OnHide", function (self)
		animator:Show();
	end);

	local text = Peggle:CreateCaption(0,0, const.locale["MENU"], obj, 25, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -20);

	obj = CreateButton(0, 0, 40, "buttonAbandonGame", true, "menuAbandon", frame, function (self)
		if (window.duelStatus == 3) then
			local frame = window.catagoryScreen.frames[2];
			SendAddonMessage(window.network.prefix, const.commands[6], "WHISPER", frame.name2:GetText());
			frame.player1.value = -2;
--			frame.result1:SetText(frame.forfeit);
			frame:UpdateWinners();
			if (PeggleData.settings.closeDuelChallenge == true) then
				window.duelStatus = nil;
				window:Hide();
			end
--			window.duelStatus = nil;
		end
		gameOver = true;
		ShowGameUI(false);
		self:GetParent():Hide();
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Top", 0, -56);

	obj = CreateButton(0, 0, 40, "buttonRestartLevel", nil, "menuRestart", frame, function (self)
		Generate(currentLevelString, const.extraInfo);
		self:GetParent():Hide();
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Top", 0, -106);
	frame.restart = obj;

	obj = CreateButton(0, 0, 40, "buttonReturnToGame", nil, "menuReturn", frame, function (self)
		self:GetParent():Hide();
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Top", 0, -156);

	return frame;

end

local function CreateCharSelector()
	
	local obj = CreateFrame("Frame", "", window.artBorder);
	obj:SetPoint("Center", gameBoard, "Center", 0, -20)
	obj:SetWidth(340);
	obj:SetHeight(260);
	obj:EnableMouse(true);

	obj:SetScript("OnLeave", function (self)
		self:SetAlpha(0.25);
	end);

	obj:SetScript("OnEnter", function (self)
		self:SetAlpha(1);
	end);

	obj:SetScript("OnShow", function (self)
		self:SetAlpha(1);
	end);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;
	windowBackdrop.bgFile = const.artPath .. "windowBackground";

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.7,0.7,0.7, 1);
	obj:SetBackdropBorderColor(1,0.8,0.45);
	local frame = obj;
	obj:Hide();
	window.charScreen = obj;

	local text = Peggle:CreateCaption(0,0, const.locale["CHAR_SELECT"], obj, 25, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -20);

	local OnMouseDown = function (self, button)
--		self.down = true;
	end

	local OnMouseUp = function (self, button)
--		self.down = nil;
		if (self.hover == true) then
--			self:SetBackdropBorderColor(1,1,0.4);
			self.tex:SetVertexColor(1, 1, 1);
			local frame = self:GetParent()
			if (frame.focus ~= self) and (frame.focus) then
--				frame.focus:SetBackdropBorderColor(0.5,1,1);
				frame.focus.tex:SetVertexColor(0.5, 0.5, 0.5);
				Sound(const.SOUND_POWERUP_GUIDE + self:GetID());
				window.shooter.face:SetTexture(const.artPath .. "char" .. (self:GetID() + 1) .. "Face");
			end
			frame.focus = self;
		end
	end

	local OnEnter = function (self)
		self:SetBackdropBorderColor(1,1,0.4);
--		self.tex:SetVertexColor(1, 1, 1);
		self.hover = true;
		self:GetParent():SetAlpha(1);
	end

	local OnLeave = function (self)
		self:SetBackdropBorderColor(0.1,0.6,0.6);
--		self.tex:SetVertexColor(0.7, 0.7, 0.7);
		self.hover = nil;
		if not MouseIsOver(self:GetParent()) then
			self:GetParent():SetAlpha(0.25);
		end
	end

	windowBackdrop.edgeFile = const.artPath .. "CharSelectBorder";

		
	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Center", -80, 0)
	obj:SetWidth(140);
	obj:SetHeight(140);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0);
	obj:SetBackdropBorderColor(0.1,0.6,0.6);
	local tex = obj:CreateTexture(nil, "Background");
	tex:SetWidth(128);
	tex:SetHeight(128);
	tex:SetTexture(const.artPath .. "char1");
	tex:SetVertexColor(1, 1, 1)
	tex:SetPoint("Center", 0, 1);
	obj.tex = tex;
	obj:EnableMouse(true);
	obj:SetScript("OnMouseDown", OnMouseDown);
	obj:SetScript("OnMouseUp", OnMouseUp);
	obj:SetScript("OnEnter", OnEnter);
	obj:SetScript("OnLeave", OnLeave);
	obj:SetID(SPECIAL_GUIDE);
	frame.focus = obj;

	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Center", 80, 0)
	obj:SetWidth(140);
	obj:SetHeight(140);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0);
	obj:SetBackdropBorderColor(0.1,0.6,0.6);
	tex = obj:CreateTexture(nil, "Background");
	tex:SetWidth(128);
	tex:SetHeight(128);
	tex:SetTexture(const.artPath .. "char2");
	tex:SetVertexColor(0.5, 0.5, 0.5)
	tex:SetPoint("Center", 0, 1);
	obj.tex = tex;
	obj:EnableMouse(true);
	obj:SetScript("OnMouseDown", OnMouseDown);
	obj:SetScript("OnMouseUp", OnMouseUp);
	obj:SetScript("OnEnter", OnEnter);
	obj:SetScript("OnLeave", OnLeave);
	obj:SetID(SPECIAL_BLAST);

	obj = CreateButton(0, 0, 40, "buttonOkay", nil, "charOkay", frame, function (self)
		local parent = self:GetParent();
		parent.focus:GetID();
		specialCount = 0;
		specialType = parent.focus:GetID();
		if (specialType == SPECIAL_GUIDE) then
			specialName = const.locale["_SPECIAL_NAME1"];
		else
			specialName = const.locale["_SPECIAL_NAME2"];
		end
		self:GetParent():Hide();
	end)
	obj.onEnter = obj:GetScript("OnEnter");
	obj.onLeave = obj:GetScript("OnLeave");
	obj:SetScript("OnEnter", function (self)
		self:GetParent():SetAlpha(1);
		obj:onEnter();
	end);
	obj:SetScript("OnLeave", function (self)
		if not MouseIsOver(self:GetParent()) then
			self:GetParent():SetAlpha(0.25);
		end
		obj:onEnter();
	end);
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", 0, 16);

	return frame;

end

local function CreateTab_QuickPlay()

	local obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 5, -9)
	obj:SetPoint("BottomRight", -4, 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.0,0.0,0.0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 1);
	tinsert(window.catagoryScreen.frames, obj);
	local frame = obj;
	obj:Hide();
	obj.showID = 1;

	window.fontObj = CreateFont("PeggleDropdownFont");
	window.fontObj:SetFont(const.artPath .. "OVERLOAD.ttf", 16);
	window.fontObj.oldSetFont = window.fontObj.SetFont;
	window.fontObj.oldGetFont = window.fontObj.GetFont;
	window.fontObj.oldGetFontObject = window.fontObj.GetFontObject;
	window.fontObj.blankFunc = function () end;
	window.fontObj.SetFont = window.fontObj.blankFunc
	window.fontObj.GetFontObject = window.fontObj.blankFunc
	window.fontObj.GetFont = window.fontObj.blankFunc

	obj:SetScript("OnShow", function (self)
--		self.info.forced = true;
--		Dropdown_Item_OnClick(self.info);
		self:UpdateDisplay(self.showID);
		window.levelList:SetParent(self);
		window.levelList:UpdateList();
		window.levelList:Show();
	end);

	obj.UpdateDisplay = function (self, levelID)

		-- Update level score
		local score = scoreData[levelID];
		if (score == 0) then
			self.beatLevel:Show();
			self.best:Hide();
			self.points:Hide();
			self.mostRecentFrame:Hide();
		else
			self.beatLevel:Hide();
			self.best:Show();
			self.points:Show();
			self.points:SetText(NumberWithCommas(score));
			self.mostRecentFrame:Show();
			self.mostRecentPoints:SetText(NumberWithCommas(PeggleData.recent[levelID]));
		end

		-- Update flags
		local flag = scoreData[levelID + 12];
		local text;
		text = self.talent2;
		if (flag == 3) then
			text:SetText(text.caption2)
			text.tex:SetTexCoord(unpack(text.tex.on));
			text:SetVertexColor(0, 1, 0);
		else
			text:SetText(text.caption1)
			text.tex:SetTexCoord(unpack(text.tex.off));
			text:SetVertexColor(1, 1, 0);
		end
		text = self.talent1;
		if (flag >= 2) then
			text:SetText(text.caption2)
			text.tex:SetTexCoord(unpack(text.tex.on));
			text:SetVertexColor(0, 1, 0);
		else
			text:SetText(text.caption1)
			text.tex:SetTexCoord(unpack(text.tex.off));
			text:SetVertexColor(1, 1, 0);
		end

		self.levelImage:SetTexture(const.artPath .. "bg" .. self.showID .. "_thumb");
		
	end


	local text = Peggle:CreateCaption(0, 0, const.locale["QUICK_PLAY"], obj, 40, 0.05, 0.66, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -22);

	local content = CreateFrame("Frame", "", frame);
	content:SetPoint("TopLeft")
	content:SetPoint("BottomRight");
	window.levelList = content;

		content.UpdateList = function (self)
			local i, flag;
			for i = 1, 12 do 
				flag = scoreData[i + 12];
				if (flag == 3) then
					self["flag" .. i .. "a"]:Show();
					self["flag" .. i .. "b"]:Show();
				elseif (flag == 2) then
					self["flag" .. i .. "a"]:Show();
					self["flag" .. i .. "b"]:Hide();
				else
					self["flag" .. i .. "a"]:Hide();
					self["flag" .. i .. "b"]:Hide();
				end
				self["highlight" .. i].tex:SetAlpha(0);
			end
			self["highlight" .. self:GetParent().showID].tex:SetAlpha(1);
		end

		text = Peggle:CreateCaption(0, 0, const.locale["SELECT_LEVEL"], content, 26, 1, 0.82, 0, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Topleft", 170, -60);

		local listBorder = CreateFrame("Frame", "", content);
		listBorder:SetPoint("Topleft", 20, -90)
		listBorder:SetPoint("Bottomleft", 20, 100);
		listBorder:SetWidth(300);
		windowBackdrop.bgFile = const.artPath .. "windowBackground";
		windowBackdrop.tileSize = 128;
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0,0,0,0.5);
		listBorder:SetBackdropBorderColor(1,0.8,0.45);

		local levelOnEnter = function (self)
			frame = self:GetParent():GetParent():GetParent();
			if (frame.showID ~= self:GetID()) then
				self.tex:SetAlpha(0.5);
			end
		end

		local levelOnLeave = function (self)
			frame = self:GetParent():GetParent():GetParent();
			if (frame.showID ~= self:GetID()) then
				self.tex:SetAlpha(0);
			end
		end

		local levelOnClick = function (self)
			local frame = self:GetParent():GetParent():GetParent();
			if (frame.showID ~= self:GetID()) then
				self:GetParent():GetParent()["highlight" .. frame.showID].tex:SetAlpha(0);
				frame.showID = self:GetID();
				frame:UpdateDisplay(self:GetID());
				self.tex:SetAlpha(1);
			end
		end

		local i, tex, seg;
		for i = 1, 12 do 

			text = Peggle:CreateCaption(10, 10 + (i - 1) * 20, i, listBorder, 19, 1, 1, 1, 1, nil)
			text:SetWidth(32);
			text:SetHeight(14);
			text:SetJustifyH("LEFT") 

			text = Peggle:CreateCaption(42, 10 + (i - 1) * 20, const.locale["_LEVEL_NAME" .. i], listBorder, 19, 1, 1, 1, 1, nil)
			text:SetWidth(300 - 42 - 42);
			text:SetHeight(14);

--			seg = const.artCut["bannerSmall1"];
			tex = listBorder:CreateTexture(nil, "Overlay");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topright", -10 - 16, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "bannerSmallRed");
--			tex:SetTexture(const.artPath .. "banner2");
--			tex:SetTexCoord(unpack(seg));
			content["flag" .. i .. "a"] = tex;

--			seg = const.artCut["bannerSmall2"];
			tex = listBorder:CreateTexture(nil, "Overlay");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topright", -10, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "bannerSmallBlue");
--			tex:SetTexture(const.artPath .. "banner2");
--			tex:SetTexCoord(unpack(seg));
			content["flag" .. i .. "b"] = tex;

			obj = CreateFrame("Frame", "", listBorder);
			obj:SetWidth(300 - 16);
			obj:SetHeight(20);
			obj:SetPoint("Topleft", 10, - 6 - (i - 1) * 20);
			obj:SetScript("OnEnter", levelOnEnter);
			obj:SetScript("OnLeave", levelOnLeave);
			obj:SetScript("OnMouseUp", levelOnClick);
			obj.tex = listBorder:CreateTexture(nil, "Artwork");
			obj.tex:SetAllPoints(obj);
			obj.tex:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
			obj.tex:SetVertexColor(0.1,0.75,1);
			obj.tex:SetAlpha(0);
			obj.tex:SetBlendMode("ADD");
			obj:EnableMouse(true);
			obj:SetID(i);
			content["highlight" .. i] = obj;
		end

	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Topright", -96 + 32 - 10 - 6, -64)
	obj:SetWidth(192 - 20 - 4);
	obj:SetHeight(192 - 20 - 4);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0);
	obj:SetBackdropBorderColor(1,1,1);

	tex = obj:CreateTexture(nil, "Background");
	tex:SetTexture(const.artPath .. "bg1_thumb");
	tex:SetPoint("Center");
	tex:SetWidth(192 - 14 - 20 - 4);
	tex:SetHeight(192 - 14 - 20 - 4);
	frame.levelImage = tex;
--[[
	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Topleft", 30, -130)
	obj:SetWidth(256 + 32);
	obj:SetHeight(256 + 32);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0);
	obj:SetBackdropBorderColor(1,1,1);

	local tex = obj:CreateTexture(nil, "Background");
	tex:SetTexture(const.artPath .. "bg1_thumb");
	tex:SetPoint("Center");
	tex:SetWidth(242 + 32);
	tex:SetHeight(242 + 32);
	frame.levelImage = tex;
--]]

--[[
	obj = CreateDropdown(30, 100, 256 - 16 + 32, "quickLevels", nil, nil, frame, frame.levelImage, nil)
	getglobal(obj:GetName() .. "Text"):ClearAllPoints();
	getglobal(obj:GetName() .. "Text"):SetPoint("Center", frame, "Topleft", 33 + (256 - 16 + 32)/2, -100 - 13);
	frame.info = obj;
--]]
	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Topright", -34, -236)
	obj:SetWidth(256);
	obj:SetHeight(60);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	frame.bestFrame = obj;

	text = Peggle:CreateCaption(0, 0, const.locale["PERSONAL_BEST"], obj, 20, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Center", 0, 12);
	text:Hide();
	frame.best = text;

	text = Peggle:CreateCaption(0, 0, "", obj, 20, 1, 1, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Center", 0, -10);
	text:Hide();
	frame.points = text;

	text = Peggle:CreateCaption(0, 0, const.locale["NO_SCORE"], obj, 20, 0, 1, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Center");
	text:SetWidth(220);
--	text:Hide();
	frame.beatLevel = text;

	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Topright", frame.bestFrame, "Bottomright", 0, -4)
	obj:SetWidth(256);
	obj:SetHeight(60);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	frame.mostRecentFrame = obj;

	text = Peggle:CreateCaption(0, 0, const.locale["MOST_RECENT"], obj, 20, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Center", 0, 12);
	text:Show();
	frame.mostRecent = text;

	text = Peggle:CreateCaption(0, 0, "", obj, 20, 1, 1, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Center", 0, -10);
	text:Show();
	frame.mostRecentPoints = text;

	local seg = const.artCut["bannerSmall1"];
	tex = frame:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("Bottomleft", frame, "BottomLeft", 50, 56);
	tex:SetTexture(const.artPath .. "banner2");
	tex:SetTexCoord(unpack(seg));
	tex.on = seg;
	tex.off = const.artCut["bannerSmall3"];

	text = Peggle:CreateCaption(0, 0, const.locale["BEAT_THIS_LEVEL1"], frame.bestFrame, 14, 0, 1, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topleft", tex, "Topright", 0, -8);
	text:SetWidth(220);
	text.caption1 = const.locale["BEAT_THIS_LEVEL1"]
	text.caption2 = const.locale["BEAT_THIS_LEVEL3"]
	frame.talent1 = text;
	text.tex = tex;

	seg = const.artCut["bannerSmall2"];
	tex = frame:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("Bottomleft", frame, "BottomLeft", 50, 10);
	tex:SetTexture(const.artPath .. "banner2");
	tex:SetTexCoord(unpack(seg));
	tex.on = seg;
	tex.off = const.artCut["bannerSmall3"];

	text = Peggle:CreateCaption(0, 0, const.locale["BEAT_THIS_LEVEL2"], frame.bestFrame, 14, 0, 1, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topleft", tex, "Topright", 0, -8);
	text:SetWidth(220);
	text.caption1 = const.locale["BEAT_THIS_LEVEL2"]
	text.caption2 = const.locale["BEAT_THIS_LEVEL4"]
	frame.talent2 = text;
	text.tex = tex;

	obj = CreateButton(0, 0, 64, "buttonGo", nil, "quickPlayGo", frame, function (self)
		const.extraInfo = nil;
		Generate(levelString[self:GetParent().showID]);
		ShowGameUI(true);
		shooterReady = false;
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Top", frame.bestFrame, "Bottom", 0, -71);
	frame.bestFrame = nil;

	return frame;

end

local function CreateTab_Duel()

	local obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 5, -9)
	obj:SetPoint("BottomRight", -4, 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.0,0.0,0.0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 1);
	tinsert(window.catagoryScreen.frames, obj);
	local frame = obj;
	obj.showID = 1;
	obj:Hide();

	obj:SetScript("OnShow", function (self)
		window.levelList:SetParent(self);
		window.levelList:UpdateList();
		window.levelList:Hide();
		if not window.duelStatus then
			if frame.go:IsVisible() then
				self.finished = nil;
				window.levelList:Show();
			end
		end
		self:UpdateDisplay(self.showID);
	end);

	obj.UpdateDisplay = function (self, levelID)
		self.showID = levelID or self.showID;
		self.levelImage:SetTexture(const.artPath .. "bg" .. self.showID .. "_thumb");
		self.levelImage2:SetTexture(const.artPath .. "bg" .. self.showID .. "_thumb");
		local win, lose = 0, 0;
		if PeggleProfile.levelTracking[levelID] then
			win, lose = strsplit(",", PeggleProfile.levelTracking[self.showID]);
		end
		window.catagoryScreen.frames[2].winLossCount:SetFormattedText("%d - %d", win, lose);
	end

	frame.playing = const.locale["PLAYING"];
	frame.forfeit = const.locale["FORFEIT"];

	frame.UpdateWinners = function (self)

		if (self.finished) then
			return;
		end

		local winner = 0;
		local frame = self;
		local result1 = frame.player1.value; --frame.result1:GetText();
		local result2 = frame.player2.value; --frame.result2:GetText();

		frame.timeRemaining:ClearAllPoints();
		frame.timeRemaining:SetPoint("Center", frame.player2, "Center", 0, -22);
		frame.timeRemaining:SetParent(frame.player2);

		if not ((result1 < 0) or (result2 < 0)) then
--		if not ((result1 == frame.playing) or (result1 == frame.forfeit) or (result2 == frame.playing) or (result2 == frame.forfeit)) then
--			if (frame.result1.temp > frame.result2.temp) then
			if (result1 > result2) then
				winner = 1;
			else
				winner = 2;
			end
		elseif ((result1 == result2) and (result1 == -2)) then
--		elseif ((result1 == result2) and (result1 == frame.forfeit)) then
			winner = 3;
		elseif (result1 == -2) and (result2 >= 0) then
--		elseif (result1 == frame.forfeit) and (result2 ~= frame.playing)  then
			winner = 2;
		elseif (result2 == -2) and (result1 >= 0) then
--		elseif (result2 == frame.forfeit) and (result1 ~= frame.playing) then
			winner = 1;
		end

		frame.player1.results:Hide();
		frame.player1.forfeit:Hide();
		frame.player1.waiting:Hide();
		frame.player2.results:Hide();
		frame.player2.forfeit:Hide();
		frame.player2.waiting:Hide();

		local results = frame.player1.results;
		if (result1 == -1) then
			frame.player1.waiting:Show();
		elseif (result1 >= 0) then
			results:Show();
			results.score:SetFormattedText(results.score.caption1, NumberWithCommas(result1));
			results.talent:SetFormattedText(results.talent.caption1, NumberWithCommas(frame.player1.value1));
			results.style:SetFormattedText(results.style.caption1, NumberWithCommas(frame.player1.value2));
			results.fever:SetFormattedText(results.fever.caption1, NumberWithCommas(frame.player1.value3));
			results.charImage:SetTexture(const.artPath .. "char" .. frame.player1.value4);
			results.redCount:SetText(frame.player1.value5);
			results.blueCount:SetText(frame.player1.value6);
		else
			frame.player1.forfeit:Show();
		end				

		results = frame.player2.results;
		if (result2 == -1) then
			frame.player2.waiting:Show();
		elseif (result2 >= 0) then
			results:Show();
			results.score:SetFormattedText(results.score.caption1, NumberWithCommas(result2));
			results.talent:SetFormattedText(results.talent.caption1, NumberWithCommas(frame.player2.value1));
			results.style:SetFormattedText(results.style.caption1, NumberWithCommas(frame.player2.value2));
			results.fever:SetFormattedText(results.fever.caption1, NumberWithCommas(frame.player2.value3));
			results.charImage:SetTexture(const.artPath .. "char" .. frame.player2.value4);
			results.redCount:SetText(frame.player2.value5);
			results.blueCount:SetText(frame.player2.value6);
		else
			frame.player2.forfeit:Show();
		end				

--		frame.duelName1:SetTextColor(1,0.82,0);
--		frame.result1:SetTextColor(1,0.82,0);
--		frame.duelName2:SetTextColor(1,0.82,0);
--		frame.result2:SetTextColor(1,0.82,0);

		local name = frame.name2:GetText();
		if (name) then
			name = gsub(name, "^%l", string.upper);
		end

		local win, lose = 0, 0;
		local levelWin, levelLose = 0, 0;

		if (winner > 0) then

			window.duelTimer:Hide()

			if (PeggleProfile.duelTracking[name]) then
				win, lose = strsplit(",", PeggleProfile.duelTracking[name]);
			end
			if (PeggleProfile.levelTracking[bgIndex]) then
				levelWin, levelLose = strsplit(",", PeggleProfile.levelTracking[bgIndex]);
			end

			self.finished = true;
			frame.publish:Hide();
			
			if (winner == 1) then
--				frame.duelName1:SetTextColor(0,1,0);
--				frame.result1:SetTextColor(0,1,0);
				Sound(const.SOUND_APPLAUSE); 
				win = win + 1;
				levelWin = levelWin + 1;
				frame.resultStatus:SetFormattedText(frame.resultStatus.caption2, name);
				frame.player1.results.score:SetTextColor(0,1,0);
				frame.player2.results.score:SetTextColor(1,0,0);
				frame.publishInfo = string.format(const.locale["_PUBLISH_DUEL_W"], UnitName("player"), name);
				frame.publish:Show();
			elseif (winner == 2) then
--				frame.duelName2:SetTextColor(0,1,0);
--				frame.result2:SetTextColor(0,1,0);
				Sound(const.SOUND_SIGH);
				lose = lose + 1;
				levelLose = levelLose + 1;
				frame.resultStatus:SetFormattedText(frame.resultStatus.caption3, name);
				frame.player1.results.score:SetTextColor(1,0,0);
				frame.player2.results.score:SetTextColor(0,1,0);
				frame.publishInfo = string.format(const.locale["_PUBLISH_DUEL_L"], UnitName("player"), name);
				frame.publish:Show();
			else
				frame.resultStatus:SetFormattedText(frame.resultStatus.caption4);
			end					

			-- Update rankings
			PeggleProfile.duelTracking[name] = tostring(win) .. "," .. tostring(lose);
			PeggleProfile.levelTracking[bgIndex] = tostring(levelWin) .. "," .. tostring(levelLose);

			-- Update the screen (it's hidden now, but when the user clicks okay, it won't be)
			frame:UpdateDisplay(frame.showID);
			frame.name2:SetText("");
			frame.name2:SetText(name);

			if (PeggleData.settings.closeDuelComplete) then
				window:Hide();
			end
		else
			frame.resultStatus:SetFormattedText(frame.resultStatus.caption1, name);
		end

		win, lose = 0, 0
		if PeggleProfile.duelTracking[name] then
			win, lose = strsplit(",", PeggleProfile.duelTracking[name]);
		end
		frame.winLossDuelsVs:SetFormattedText(frame.winLossDuelsVs.caption1, name, win, lose);

		win, lose = 0, 0
		local strWin, strLose;
		local i;
		for i = 1, 12 do 
			if PeggleProfile.levelTracking[i] then
				strWin, strLose = strsplit(",", PeggleProfile.levelTracking[i]);
				win = win + tonumber(strWin);
				lose = lose + tonumber(strLose);
			end
		end
		frame.winLossDuels:SetFormattedText(frame.winLossDuels.caption1, win, lose);

	end

--[[
	obj = CreateDropdown(30, 100, 256 - 16 + 32, "duelLevels", nil, nil, frame, frame.levelImage, nil)
	getglobal(obj:GetName() .. "Text"):ClearAllPoints();
	getglobal(obj:GetName() .. "Text"):SetPoint("Center", frame, "Topleft", 33 + (256 - 16 + 32)/2, -100 - 13);
	frame.info = obj;
--	frame.info:SetParent(frame);
--]]

	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Topright", -35, -200)
	obj:SetWidth(256);
	obj:SetHeight(128);
	frame.duelInfo1 = obj;

	local text = Peggle:CreateCaption(0, 0, const.locale["DUEL"], obj, 40, 0.05, 0.66, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame, "Top", 0, -22);
	text:SetParent(obj);

	obj = CreateFrame("Frame", "", frame.duelInfo1);
	obj:SetPoint("Topright", frame, "Topright", -98, -60)
	obj:SetWidth(128);
	obj:SetHeight(128);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0);
	obj:SetBackdropBorderColor(1,1,1);

	tex = obj:CreateTexture(nil, "Background");
	tex:SetTexture(const.artPath .. "bg1_thumb");
	tex:SetPoint("Center");
	tex:SetWidth(128 - 14);
	tex:SetHeight(128 - 14);
	frame.levelImage = tex;

	text = Peggle:CreateCaption(0, 0, const.locale["OPPONENT"], frame.duelInfo1, 20, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Bottom", 2, -10);
	text.caption1 = text:GetText();
	text.caption2 = const.locale["DUEL_CHALLENGE"];
	frame.name1 = text;

	text = CreateTextbox(0, 0, 256, "opponentName", frame.duelInfo1, nil, nil, nil, tooltipText)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Bottom", 0, -30);
--	text:SetFontObject(window.fontObj);
	frame.name2 = text;

	text:SetScript("OnTextChanged", function (self)

		local parent = self:GetParent():GetParent();
		local name = self:GetText();
	
		if (name) then
			
			name = gsub(name, "^%l", string.upper);
			parent.winLossPlayer:Show();

			local win, lose = 0, 0
			if PeggleProfile.duelTracking[name] then
				win, lose = strsplit(",", PeggleProfile.duelTracking[name]);
			end
			
			parent.winLossPlayer:SetFormattedText(parent.winLossPlayer.caption1, win, lose);

		else
			parent.winLossPlayer:Hide();
		end

	end);

	local dropObj = CreateDropdown(0, 0, 256, "duelNames", nil, nil, text, nil, nil)
	dropObj.names = true;
	dropObj:DisableDrawLayer("ARTWORK");
	dropObj:ClearAllPoints();
	dropObj:SetPoint("Topright", text, "Topright", 18, -3);
	frame.nameDrop = dropObj;

	text = Peggle:CreateCaption(0, 0, const.locale["WIN_LOSS_PLAYER"], frame.duelInfo1, 18, 1, 0.82, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Bottom", 0, -62);
	text.caption1 = text:GetText();
	frame.winLossPlayer = text;
	text:Hide();

	text = Peggle:CreateCaption(0, 0, const.locale["OPPONENT_NOTE"] .. " " ..  const.locale["OPTIONAL"], frame.duelInfo1, 20, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Bottom", 0, -100);
	text.caption1 = text:GetText();
	text.caption2 = const.locale["OPPONENT_NOTE"];
	text.caption3 = const.locale["OPPONENT_NOTE2"];
	frame.note1 = text;

	text = CreateTextbox(0, 0, 256, "opponentNote", frame.duelInfo1, nil, nil, nil, tooltipText)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Bottom", 0, -120);
--	text:SetFontObject(window.fontObj);
	text:SetMaxBytes(48);
	frame.note2 = text;

	text = Peggle:CreateCaption(0, 0, "", frame.duelInfo1, 12, 1, 1, 1, nil, "")
	--CreateTextbox(0, 0, 256, "opponentNote", obj, nil, nil, nil, tooltipText)
	text:ClearAllPoints();
	text:SetPoint("Top", obj, "Bottom", 0, -126);
	text:SetWidth(256);
	text:SetHeight(14*2);
	text:SetJustifyV("TOP");
	text:SetFontObject(window.fontObj);
	text:Hide();
	frame.note2a = text;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_STATUS"], frame.duelInfo1, 24, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame, "Topleft", 170, -120);
	text:SetWidth(256);
	frame.note3Title = text;
	text:Hide();

	text = Peggle:CreateCaption(0, 0, "", frame.duelInfo1, 18, 1, 1, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame, "Topleft", 170, -180); --obj, "Top", 0, -81);
	text:SetWidth(256);
	text.status1 = const.locale["DUEL_STATUS1"];
	text.status2 = const.locale["DUEL_STATUS2"];
	text.status3 = const.locale["DUEL_STATUS3"];
	text.status4 = const.locale["DUEL_STATUS4"];
	text.status5 = const.locale["DUEL_STATUS5"];
	text.status6 = const.locale["DUEL_STATUS6"];
	frame.note3 = text;

	text = Peggle:CreateCaption(0, 0, const.locale["WIN_LOSS"], obj, 20, 0, 1, 0, mil, nil)
	text:ClearAllPoints();
	text:SetPoint("Topleft", frame, "Bottomleft", 20, 90);
	text:SetWidth(300);
	frame.winLoss = text;

	text = Peggle:CreateCaption(0, 0, const.locale["WIN_LOSS_LEVEL"], obj, 12, 0, 1, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame.winLoss , "Bottom", 0, -4);
	text:SetWidth(300);
	frame.winLossLevel = text;

	text = Peggle:CreateCaption(0, 0, "0 - 0", obj, 26, 0, 1, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame.winLossLevel, "Bottom", 0, -6);
	text:SetWidth(300);
	frame.winLossCount = text;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_TIME"], frame, 14, 1, 0.82, 0, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame.winLossCount, "Bottom", 0, -6);
	text:SetWidth(300);
	text.caption1 = text:GetText();
	text:Hide();
	frame.timeRemaining = text;

	obj = CreateButton(0, 0, 64, "buttonGo", nil, "8", frame.duelInfo1, function (self)
		local frame = self:GetParent():GetParent();
		local challengeName = frame.name2:GetText() or "";
		if (challengeName ~= "") then
			self:Hide();

			ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Net_ChatFilter)

	--		getglobal(frame.info:GetName() .. "Text"):SetParent(frame);
	--		frame.info:Hide();
			window.levelList:Hide();

			frame.winLoss:ClearAllPoints();
			frame.winLoss:SetPoint("Topleft", frame, "Bottomleft", 20, 190);

--			frame.winLoss:Hide();
--			frame.winLossLevel:Hide();
--			frame.winLossCount:Hide();

			frame.nameDrop:Hide();
			frame.name2:DisableDrawLayer("BACKGROUND");
			frame.name2:SetJustifyH("CENTER") 
			frame.name2:EnableMouse(false);
			frame.name2:ClearFocus();
			frame.note1:SetText(frame.note1.caption2);
			frame.note2a:SetText(frame.note2:GetText() or NONE);
			frame.note2a:Show();
			frame.note2:Hide();
			frame.note3:Show();
			frame.note3:SetText(frame.note3.status1);
			frame.note3Title:Show();
			frame.decline1:Show();

			-- Build the default starting peg layout for the game
	
			DeserializeLevel(levelString[frame.showID]);

			local totalPegs = #objects;
			local temp = {};
			local i, j;
			local pegGroup = "";
			for i = 1, totalPegs do 
				tinsert(temp, i);
			end

			for i = 1, 25 do 
				j = random(1, #temp);
				pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);
			end

			local greenRadius = (thePegRadius * 9)^2;
			local greenFound;
			local lastGreen;

			-- 2 pegs for green
			for i = 1, 2 do 
				j = random(1, #temp);
				greenFound = nil;
				while (greenFound == nil) do 
					if (lastGreen) then
						if (((objects[temp[j]].x - objects[temp[lastGreen]].x)^2) + ((objects[temp[j]].y - objects[temp[lastGreen]].y)^2)) < greenRadius then
							if (#temp > 0) then
								j = random(1, #temp);
							end
						else
							greenFound = true;
						end
					else
						lastGreen = j;
						greenFound = true;
					end
				end
				pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);
			end

			-- and 1 peg for purple
			j = random(1, #temp);
			pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);

			frame.levelInfo = pegGroup;
			pegGroup = DataPack(pegGroup, SeedFromName(const.name));
			collectgarbage();

			window.duelTimer.elapsed = 0;
			window.duelTimer.remaining = 300;
			window.duelTimer:Show()

			window.duelStatus = 1;
			window.network.inviteTimer = 0;
			window.network.watchError = challengeName;
			local duelText = frame.note2:GetText() or "";
			if (duelText == "") then
				duelText = NONE;
			end
			SendAddonMessage(window.network.prefix, const.commands[1] .. "+" .. frame.showID .. "+" .. duelText .. "+" .. pegGroup, "WHISPER", challengeName);
		end

	end)
	obj:ClearAllPoints();
	obj:SetPoint("Top", frame.duelInfo1, "Bottom", 0, -28);
	frame.go = obj;

	obj = CreateButton(0, 0, 64, "buttonDecline", true, "duelDecline1", frame.duelInfo1, function (self)
		self:Hide();
		window.duelTimer:Hide()
		
		local frame = self:GetParent():GetParent();
--		getglobal(frame.info:GetName() .. "Text"):SetParent(frame.info);

		window.duelStatus = nil;

		frame.nameDrop:Show();
		window.levelList:Show();

		frame.winLoss:ClearAllPoints();
		frame.winLoss:SetPoint("Topleft", frame, "Bottomleft", 20, 90);

--		frame.winLoss:Show();
--		frame.winLossLevel:Show();
--		frame.winLossCount:Show();

--		frame.info:Show();
		frame.go:Show();
--		frame.info:EnableDrawLayer("BACKGROUND");
		frame.name2:EnableDrawLayer("BACKGROUND");
		frame.name2:SetJustifyH("LEFT");
		frame.name2:EnableMouse(true);
		frame.note1:SetText(frame.note1.caption1);
		frame.note2:Show();
		frame.note2a:Hide();
		frame.note3:Hide();
		frame.note3Title:Hide();

		SendAddonMessage(window.network.prefix, const.commands[7] .. "+", "WHISPER", frame.name2:GetText());

	end, nil, true)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", frame, "Bottom", 0, 16);
	obj:Hide();
	frame.decline1 = obj;

	obj = CreateButton(0, 0, 64, "buttonOkay", nil, "duelOkay1", frame.duelInfo1, function (self)
		self:Hide();

		local frame = self:GetParent():GetParent();
--		getglobal(frame.info:GetName() .. "Text"):SetParent(frame.info);
--		frame.info:Show();
		window.levelList:Show();

		frame.winLoss:ClearAllPoints();
		frame.winLoss:SetPoint("Topleft", frame, "Bottomleft", 20, 90);
		frame.winLoss:Show();
		frame.winLossLevel:Show();
		frame.winLossCount:Show();

		frame.go:Show();
--		frame.info:EnableDrawLayer("BACKGROUND");
		frame.nameDrop:Show();		
		frame.name2:EnableDrawLayer("BACKGROUND");
		frame.name2:SetJustifyH("LEFT");
		frame.name2:EnableMouse(true);
		frame.note1:SetText(frame.note1.caption1);
		frame.note2:Show();
		frame.note2a:Hide();
		frame.note3:Hide();
		frame.note3Title:Hide();

		window.duelStatus = nil
		window.network.inviteTimer = nil;
		window.network.watchError = nil;

	end)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", frame, "Bottom", 0, 16);
--	obj:SetPoint("Top", frame.duelInfo1, "Bottom", 0, -18);
	obj:Hide();
	frame.okay1 = obj;

	obj = CreateButton(0, 0, 64, "buttonGo", nil, "duelOkay2", frame.duelInfo1, function (self)
		self:Hide();

		local frame = self:GetParent():GetParent();
		frame.decline2:Hide();
		SendAddonMessage(window.network.prefix, const.commands[4] .. "+", "WHISPER", frame.name2:GetText());

		window.minimap.notice = nil;

--		getglobal(frame.info:GetName() .. "Text"):SetParent(frame);
--		frame.info:Hide();
		window.levelList:Hide();
		frame.winLoss:Hide();
		frame.winLossLevel:Hide();
		frame.winLossCount:Hide();

		frame.nameDrop:Hide();		
		frame.duelInfo1:Hide();
		frame.duelInfo2:Show();

		frame.go:Show();
		frame.okay1:Hide();
		frame.okay2:Hide();
		frame.decline1:Hide();
		frame.decline2:Hide();
--		frame.info:EnableDrawLayer("BACKGROUND");
		frame.name2:EnableDrawLayer("BACKGROUND");
		frame.name2:SetJustifyH("LEFT");
		frame.name2:EnableMouse(true);
		frame.note1:SetText(frame.note1.caption1);
		frame.note2:Show();
		frame.note2a:Hide();
		frame.note3:Hide();
		frame.note3Title:Hide();

		local i
		for i = 1, 6 do 
			frame.player1["value" .. i] = 0;
			frame.player2["value" .. i] = 0;
		end
		frame.player1.value = -1;
		frame.player2.value = -1;

--		frame.duelName1:SetText(UnitName("player"));
--		frame.duelName2:SetText(frame.name2:GetText());
--		frame.result1:SetText(frame.playing);
--		frame.result2:SetText(frame.playing);
--		frame.result1.temp = 0;
--		frame.result2.temp = 0;
--		frame.duelName1:SetTextColor(1, 0.82, 0);
--		frame.duelName2:SetTextColor(1, 0.82, 0);
--		frame.result1:SetTextColor(1, 0.82, 0);
--		frame.result2:SetTextColor(1, 0.82, 0);

		window.duelTab.sparks:Hide();

		-- Start the level
		Generate(levelString[frame.showID], nil, frame.levelInfo);
		ShowGameUI(true);
		shooterReady = false;

		window.duelStatus = 3;
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", frame, "Bottom", -150, 16);
	obj:Hide();
	frame.okay2 = obj;

	obj = CreateButton(0, 0, 64, "buttonDecline", true, "duelDecline2", frame.duelInfo1, function (self)
		self:Hide();
		window.duelTimer:Hide()

		local frame = self:GetParent():GetParent();
		frame.okay2:Hide();

		window.minimap.notice = nil;
		window.duelTab.sparks:Hide();

--		getglobal(frame.info:GetName() .. "Text"):SetParent(frame.info);
--		frame.info:Show();
--		frame.info:EnableDrawLayer("BACKGROUND");
		frame.nameDrop:Show();		
		window.levelList:Show();

		frame.winLoss:ClearAllPoints();
		frame.winLoss:SetPoint("Topleft", frame, "Bottomleft", 20, 90);
--		frame.winLoss:Show();
--		frame.winLossLevel:Show();
--		frame.winLossCount:Show();

		frame.name2:EnableDrawLayer("BACKGROUND");
		frame.name2:SetJustifyH("LEFT");
		frame.name2:EnableMouse(true);
		frame.note1:SetText(frame.note1.caption1);
		frame.note2:Show();
		frame.note2a:Hide();
		frame.note2:SetText("");
		frame.note3:Hide();
		frame.note3Title:Hide();

		frame.go:Show();

		SendAddonMessage(window.network.prefix, const.commands[3] .. "+", "WHISPER", frame.name2:GetText());

		window.duelStatus = nil;

	end, nil, true)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", frame, "Bottom", 150, 16);
--	obj:SetPoint("Top", frame.duelInfo1, "Bottom", 60, -98);
	obj:Hide();
	frame.decline2 = obj;
	
	obj = CreateFrame("Frame", "", frame);
	obj:SetPoint("Topright", -35, -160)
	obj:SetWidth(256);
	obj:SetHeight(128);
	obj:Hide();
	frame.duelInfo2 = obj;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_RESULTS"], frame.duelInfo2 , 40, 0.05, 0.66, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame, "Top", 0, -22);
	text:SetParent(obj);

	obj = CreateFrame("Frame", "", frame.duelInfo2);
	obj:SetPoint("Topleft", frame, "Topleft", 98, -60)
	obj:SetWidth(128);
	obj:SetHeight(128);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0);
	obj:SetBackdropBorderColor(1,1,1);

	tex = obj:CreateTexture(nil, "Background");
	tex:SetTexture(const.artPath .. "bg1_thumb");
	tex:SetPoint("Center");
	tex:SetWidth(128 - 14);
	tex:SetHeight(128 - 14);
	frame.levelImage2 = tex;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_RESULT1"], frame.duelInfo2, 25, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Topleft", obj, "Topright", 10, -10);
	text:SetPoint("Bottomright", frame, "Topright", -10, -60 - 55 - 10);
	text:SetJustifyV("TOP")
	text.caption1 = const.locale["DUEL_RESULT1"];
	text.caption2 = const.locale["DUEL_RESULT2"];
	text.caption3 = const.locale["DUEL_RESULT3"];
	text.caption4 = const.locale["DUEL_RESULT4"];
	frame.resultStatus = text;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_TOTAL_WL"], frame.duelInfo2, 16, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame.resultStatus, "Bottom", 0, -10);
	text:SetWidth(400);
	text.caption1 = const.locale["DUEL_TOTAL_WL"]
	frame.winLossDuels = text;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_OPP_WL"], frame.duelInfo2, 16, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame.winLossDuels, "Bottom", 0, -6);
	text:SetWidth(400);
	text.caption1 = const.locale["DUEL_OPP_WL"]
	frame.winLossDuelsVs = text;

	-- Player one area
	-- ====================================================================

	obj = CreateFrame("Frame", "", frame.duelInfo2 );
	obj:SetPoint("Topleft", frame, "Topleft", 10, -190)
	obj:SetPoint("Topright", frame, "Topright", -10, -190)
	obj:SetHeight(88);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj.value = -1;
	obj.value1 = 0;
	obj.value2 = 0;
	obj.value3 = 0;
	obj.value4 = 1;
	obj.value5 = 0;
	obj.value6 = 0;
	frame.player1 = obj;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_WAITING"], obj, 25, 1, 0.82, 0, 1, nil)
	text:SetAllPoints(obj);
	text:SetJustifyV("MIDDLE")
	frame.player1.waiting = text;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_FORFEIT1"], obj, 25, 1, 0.82, 0, 1, nil)
	text:SetAllPoints(obj);
	text:SetJustifyV("MIDDLE")
	frame.player1.forfeit = text;

	obj = CreateFrame("Frame", "", obj);
	obj:SetAllPoints(frame.player1);
	frame.player1.results = obj;
	obj:Hide();

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "char1");
	tex:SetPoint("Topleft", 16, -12);
	tex:SetWidth(64);
	tex:SetHeight(64);
	obj.charImage = tex;

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "bannerSmallRed");
	tex:SetPoint("Topleft", 64 + 32, -12 - 32 - 4);
	tex:SetWidth(24);
	tex:SetHeight(24);

	text = Peggle:CreateCaption(64+32+2, 12+4+32+6, "11", obj, 12, 1, 1, 1, 1, nil)
	text:SetWidth(24);
	obj.redCount = text;

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "bannerSmallBlue");
	tex:SetPoint("Topleft", 64 + 32 + 32-8, -12 - 32 - 4);
	tex:SetWidth(24);
	tex:SetHeight(24);

	text = Peggle:CreateCaption(64+32+32+2-8, 12+4+32+6, "8", obj, 12, 1, 1, 1, 1, nil)
	text:SetWidth(24);
	obj.blueCount = text;

	text = Peggle:CreateCaption(8, 12+4, "", obj, 25, 1, 0.82, 0, 1, nil)
	text:SetWidth(obj:GetWidth() - 16);
	text.caption1 = const.locale["DUEL_BREAKDOWN1"]
	obj.score = text;

	text = Peggle:CreateCaption(64+32+8+64-2-7, 12 + 32+8, "", obj, 18, 0.05, 0.66, 1, 1, nil)
	text.caption1 = const.locale["DUEL_BREAKDOWN2"]
	obj.talent = text;

	text = Peggle:CreateCaption(64+32+8+64+150-2, 12 + 32+8, "", obj, 18, 0.05, 0.66, 1, 1, nil)
	text.caption1 = const.locale["DUEL_BREAKDOWN3"]
	obj.style = text;
	
	text = Peggle:CreateCaption(64+32+8+64+300, 12 + 32+8, "", obj, 18, 0.05, 0.66, 1, 1, nil)
	text.caption1 = const.locale["DUEL_BREAKDOWN4"]
	obj.fever = text;

	-- Player two area
	-- ====================================================================

	obj = CreateFrame("Frame", "", frame.duelInfo2 );
	obj:SetPoint("Topleft", frame, "Topleft", 10, -190 - 86)
	obj:SetPoint("Topright", frame, "Topright", -10, -190 - 86)
	obj:SetHeight(88);
	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0,0,0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj.value = -1;
	obj.value1 = 0;
	obj.value2 = 0;
	obj.value3 = 0;
	obj.value4 = 1;
	obj.value5 = 0;
	obj.value6 = 0;
	frame.player2 = obj;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_WAITING"], obj, 25, 1, 0.82, 0, 1, nil)
	text:SetAllPoints(obj);
	text:SetJustifyV("MIDDLE")
	frame.player2.waiting = text;

	text = Peggle:CreateCaption(0, 0, const.locale["DUEL_FORFEIT2"], obj, 25, 1, 0.82, 0, 1, nil)
	text:SetAllPoints(obj);
	text:SetJustifyV("MIDDLE")
	frame.player2.forfeit = text;

	obj = CreateFrame("Frame", "", obj);
	obj:SetAllPoints(frame.player2);
	frame.player2.results = obj;
	obj:Hide();

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "char1");
	tex:SetPoint("Topleft", 15, -11);
	tex:SetWidth(64);
	tex:SetHeight(64);
	obj.charImage = tex;

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "bannerSmallRed");
	tex:SetPoint("Topleft", 64 + 32, -12 - 32 - 4);
	tex:SetWidth(24);
	tex:SetHeight(24);

	text = Peggle:CreateCaption(64+32+2, 12+4+32+6, "11", obj, 12, 1, 1, 1, 1, nil)
	text:SetWidth(24);
	obj.redCount = text;

	tex = obj:CreateTexture(nil, "Artwork");
	tex:SetTexture(const.artPath .. "bannerSmallBlue");
	tex:SetPoint("Topleft", 64 + 32 + 32-8, -12 - 32 - 4);
	tex:SetWidth(24);
	tex:SetHeight(24);

	text = Peggle:CreateCaption(64+32+32+2-8, 12+4+32+6, "8", obj, 12, 1, 1, 1, 1, nil)
	text:SetWidth(24);
	obj.blueCount = text;

	text = Peggle:CreateCaption(8, 12+4, "", obj, 25, 1, 0.82, 0, 1, nil)
	text:SetWidth(obj:GetWidth() - 16);
	text.caption1 = const.locale["DUEL_BREAKDOWN1a"]
	obj.score = text;

	text = Peggle:CreateCaption(64+32+8+64-2-7, 12 + 32+8, "", obj, 18, 0.05, 0.66, 1, 1, nil)
	text.caption1 = const.locale["DUEL_BREAKDOWN2"]
	obj.talent = text;

	text = Peggle:CreateCaption(64+32+8+64+150-2, 12 + 32+8, "", obj, 18, 0.05, 0.66, 1, 1, nil)
	text.caption1 = const.locale["DUEL_BREAKDOWN3"]
	obj.style = text;
	
	text = Peggle:CreateCaption(64+32+8+64+300, 12 + 32+8, "", obj, 18, 0.05, 0.66, 1, 1, nil)
	text.caption1 = const.locale["DUEL_BREAKDOWN4"]
	obj.fever = text;

	

--	text = Peggle:CreateCaption(12, 10, "Moongaze", obj, 12, 1, 0.82, 0, nil, nil)
--	frame.duelName1 = text;
--	text = Peggle:CreateCaption(12, 30, "SomeoneWithALongName", obj, 12, 1, 0.82, 0, nil, nil)
--	frame.duelName2 = text;

--	text = Peggle:CreateCaption(10, 10, const.locale["PLAYING"], obj, 12, 1, 0.82, 0, nil, nil)
--	text:ClearAllPoints();
--	text:SetPoint("Topright", obj, "Topright", -10, -10);
--	text:SetJustifyH("RIGHT") 
--	frame.result1 = text;

--	text = Peggle:CreateCaption(10, 30, const.locale["PLAYING"], obj, 12, 1, 0.82, 0, nil, nil)
--	text:ClearAllPoints();
--	text:SetPoint("Topright", obj, "Topright", -10, -30);
--	text:SetJustifyH("RIGHT") 
--	frame.result2 = text;
	
	obj = CreateButton(0, 0, 64, "buttonOkay", nil, "duelOkay", frame.duelInfo2, function (self)
		local frame = self:GetParent():GetParent();
--		getglobal(frame.info:GetName().."Text"):SetParent(frame.info);
--		frame.info:Show();
		frame.nameDrop:Show();		
		window.levelList:Show();

		frame.winLoss:ClearAllPoints();
		frame.winLoss:SetPoint("Topleft", frame, "Bottomleft", 20, 90);
		frame.winLoss:Show();
		frame.winLossLevel:Show();
		frame.winLossCount:Show();
		frame.note3Title:Hide();

		window.duelStatus = nil;
		frame.finished = nil;

		frame.duelInfo1:Show();
		frame.duelInfo2:Hide();

	end)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", frame, "Bottom", 0, 16);
--	obj:SetPoint("Top", frame.duelInfo2, "Bottom", 0, -18);
	frame.okay3 = obj;

	obj = CreateButton(0, 0, 64, "buttonPublish", true, "duelPublish", frame.duelInfo2, function (self)
		window.summaryScreen.publishInfo = self:GetParent():GetParent().publishInfo;
		window.summaryScreen.publishDuel = true;
		window.summaryScreen.bragScreen:SetParent(window.catagoryScreen.frames[2]);
		window.summaryScreen.bragScreen:SetFrameLevel(window.catagoryScreen.frames[2]:GetFrameLevel() + 10);
		window.summaryScreen.bragScreen:Show();
--		window.catagoryScreen.frames[2].publish:Hide();
--		self:GetParent().bragScreen:Show();
--		self:Hide();
--		SendChatMessage(self:GetParent():GetParent().publishInfo, const.channels[PeggleData.settings.defaultPublish]);
--		self:GetParent():GetParent().publishInfo = nil;
	end, nil, true)
	obj:ClearAllPoints();
	obj:SetPoint("Bottomright", frame, "Bottomright", -16, 16);
	obj:Hide();
	frame.publish = obj;

	-- Duel timer tracker
	-- ========================================

	obj = CreateFrame("Frame", "", UIParent);
	obj:SetWidth(10);
	obj:SetHeight(10);
	obj:SetPoint("Right");
	obj:Hide();
	obj.elapsed = 0;
	obj.remaining = 300;
	obj:SetScript("OnShow", function (self)
		local frame = window.catagoryScreen.frames[2];
		local text = frame.timeRemaining;
		text:ClearAllPoints();
		text:SetPoint("Top", frame.winLossCount, "Bottom", 0, -6);
		text:SetFormattedText(text.caption1, "5m 0s");
		text:Show()
		text:SetParent(frame);
	end);
	obj:SetScript("OnHide", function (self)
		window.catagoryScreen.frames[2].timeRemaining:Hide()
	end);

	obj:SetScript("OnUpdate", function (self, elapsed)
		self.elapsed = self.elapsed + elapsed;
		if (self.elapsed >= 1) then
			self.elapsed = 0;
			self.remaining = self.remaining - 1;
			if (self.remaining <= 0) then
				self.remaining = 0;
				self:Hide();
				if (window.duelStatus == 3) then
					-- Force a forfeit if we didn't finish the level in time
					if (gameOver == false) and not window.catagoryScreen:IsShown() then
						local button = getglobal("PeggleButton_menuAbandon");
						button:GetScript("OnClick")(button);
					end
				end
				if (window.duelStatus == 2) then
					local button = getglobal("PeggleButton_duelDecline2");
					if (button:IsVisible()) then
						button:GetScript("OnClick")(button);
					else
						button = getglobal("PeggleButton_duelDecline1");
						if (button:IsVisible()) then
							button:GetScript("OnClick")(button);
						end
					end
				end
			else
				local minutes, seconds = Peggle.TimeBreakdown(ceil(self.remaining));
				if (minutes > 0) then
					minutes = minutes .. "m "
				else
					minutes = "";
				end
				if (seconds > 0) then
					seconds = seconds .. "s";
				else
					seconds = ""	
				end
				-- Update timers for duel in-game and
				if (window.duelStatus == 3) and (window.catagoryScreen.frames[2].player1.value == -1) then
					window.bestScoreCaption:SetFormattedText(window.bestScoreCaption.caption2, minutes .. seconds);
				end
				local frame = window.catagoryScreen.frames[2];
				frame.timeRemaining:SetFormattedText(frame.timeRemaining.caption1, minutes .. seconds);

				-- out of game
			end
		end
	end);
	window.duelTimer = obj;

	return frame;

end

local function CreateTab_Challenge()

	local obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 5, -9)
	obj:SetPoint("BottomRight", -4, 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.0,0.0,0.0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 1);
	tinsert(window.catagoryScreen.frames, obj);
	local frame = obj;
	obj:Hide();

	obj:SetScript("OnShow", function (self)
		self.content1.state = 0;
		self.content2:Hide();
		self.content1:Hide();
		self.content1:Show();
	end);

	-- Challenge list screen
	-- ========================================================
--[[	["CHALLENGE_DESC"] = "SELECT A CHALLENGE TO VIEW ITS DETAILS\nOR CREATE A NEW CHALLENGE!",
	["CHALLENGE_DESC1"] = "SHIFT-CLICKING A NAME WILL QUICKLY ADD/REMOVE NAMES!",
	["CHALLENGE_DESC2"] = "CHAT CHANNELS: ADDING A CUSTOM CHAT CHANNEL WILL INVITE ALL IN THE CHAT CHANNEL AT THE TIME OF CHALLENGE CREATION. THIS WILL NOT INVITE OFFLINE USERS, NOR USERS WHO DO NOT HAVE THE ADDON INSTALLED."
	["CHALLENGE_DESC3"] = "Note: Offline users will not receive the challenge until they come online while another invitee or you are also online.
	["CHALLENGE_CAT1"] = "CHALLENGER",
	["CHALLENGE_CAT2"] = "Level",
	["CHALLENGE_CAT3"] = "Shots",
	["CHALLENGE_CAT4"] = "Replays",
	["CHALLENGE_CAT5"] = "TIME LEFT",
	["CHALLENGE_CAT6"] = "Note:",
	["CHALLENGE_DUR"] = "CHALLENGE DURATION",
	["CHALLENGE_NEW"] = "NEW CHALLENGE",
	["CHALLENGE_NONE"] = "NO CHALLENGE SELECTED",
	["CHALLENGE_PLAYER"] = "PLAYER DETAILS",
	["CHALLENGE_SHOTS"] = "NUMBER OF SHOTS",
	["CHALLENGE_REPLAYS"] = "NUMBER OF REPLAYS",
--]]
	local content = CreateFrame("Frame", "", frame);
	content:SetPoint("TopLeft")
	content:SetPoint("BottomRight");
	frame.content1 = content;
	content.state = 0;

	content:SetScript("OnShow", function (content)
		window.catagoryScreen.frames[3].content2.active = nil;
		if (content.state == 0) then
			local i;
			for i = 1, 13 do 
				content["highlight" .. i].tex:SetAlpha(0);
			end
			content.showID = nil;
			window.challengeTabSparks:Hide();
			content.title:SetText(content.title.caption1);
			content.catagory1:SetText(content.catagory1.caption1);
			content.newChallenge:Show();
			content.details:Hide();
--			content.startChallenge:Hide();
			content.startChallenge1:Hide();
			content.backChallenge:Hide();
			content.noneSelected:Show();
--			content.stageInfo1:Hide();
--			content.stageInfo2:Hide();
--			content.stageInfo4:Hide();
--			content.stageInfo1a:Hide();
--			content.stageInfo2a:Hide();
--			content.stageInfo4a:Hide();
--			content.challengerCaption:Hide();
--			content.challenger:Hide();
--			content.timeLeftCaption:Hide();
--			content.timeLeft:Hide();
--			content.levelImage:Hide();
--			for i = 1, 13 do
--				content["info" .. i .. "a"]:Hide();
--				content["info" .. i .. "b"]:Hide();
--				content["info" .. i .. "b1"]:Hide();
--				content["info" .. i .. "c"]:Hide();
--				content["info" .. i .. "c1"]:Hide();
--			end

			for i = 1, 6 do 
				content["stageDetails" .. i]:Hide();
				content["stageDetails" .. i .. "a"]:Hide();
			end
			content.levelImage1:Hide();
			content.nameList:Hide();

		elseif (content.state == 1) then
--[[			
			content.title:SetText(content.title.caption2);
			content.catagory1:SetText(content.catagory1.caption2);
			content.details:Show();
			content.newChallenge:Hide();
--			content.startChallenge:Show();
			content.startChallenge1:Hide();
			content.backChallenge:Hide();
			content.noneSelected:Hide();
--			content.stageInfo1:Show();
--			content.stageInfo2:Show();
--			content.stageInfo4:Show();
--			content.stageInfo1a:Show();
--			content.stageInfo2a:Show();
--			content.stageInfo4a:Show();
--			content.challengerCaption:Show();
--			content.challenger:Show();
--			content.timeLeftCaption:Show();
--			content.timeLeft:Show();
			content.levelImage:Show();
--			for i = 1, 13 do
--				content["info" .. i .. "a"]:Show();
--				content["info" .. i .. "b"]:Show();
--				content["info" .. i .. "b1"]:Show();
--				content["info" .. i .. "c"]:Show();
--				content["info" .. i .. "c1"]:Show();
--			end
			for i = 1, 6 do 
				content["stageDetails" .. i]:Hide();
				content["stageDetails" .. i .. "a"]:Hide();
			end
			content.levelImage1:Hide();
			conteny.nameList:Show();
--]]
		else
			window.challengeTabSparks:Hide();
			content.details:Show();
			content.startChallenge1:Show();
			content.backChallenge:Show();
			content.noneSelected:Hide();
			for i = 1, 6 do 
				content["stageDetails" .. i]:Show();
				content["stageDetails" .. i .. "a"]:Show();
			end
			content.levelImage1:Show();
			content.nameList:Show();
		end
		content:UpdateScreen(true);
	end);

	content.UpdateScreen = function (self, dirty)
		local content = self;
		local challengeGroup = playerChallenges;
		local i, challenge;
		local infoList = const.newInfo;
		local name;

		if (self.state == 0) or (self.state == 2) then
			self.extraInfo = nil;
			content.listSlider:SetMinMaxValues(0, max(0, #challengeGroup - 13));
			if (content.listSlider:GetValue() > (max(0, (#challengeGroup - 13)))) then
				content.listSlider:SetValue(max(0, #challengeGroup - 13));
			end

			if (const.cCount > 4) then
				SetDesaturation(content.newChallenge.background, true);
				content.newChallenge:EnableMouse(false);
			else
				SetDesaturation(content.newChallenge.background, false);
				content.newChallenge:EnableMouse(true);
			end

			local offset = content.listSlider:GetValue();
			local hours, minutes
			for i = 1, 13 do 
				content["highlight" .. i].tex:SetAlpha(0);
				if (content.showID == i + offset) then
					content["highlight" .. i].tex:SetAlpha(1);
				end
				challenge = challengeGroup[i + offset];
				content["info" .. i .. "1"]:SetTextColor(1,1,1)
				content["info" .. i .. "2"]:SetTextColor(1,1,1);
				if (challenge) and (challenge[DATA]) then
					name = challenge[infoList[4]];
					if (challenge[infoList[6]]) then
						content["info" .. i .. "New"]:Show();
					else
						content["info" .. i .. "New"]:Hide();
					end
					if (challenge[infoList[10]]) then
						challenge[infoList[6]] = nil;
						content["info" .. i .. "New"]:Hide();
						content["info" .. i .. "Played"]:Show();
					end

					content["info" .. i .. "1"]:SetText(name);
--					content["info" .. i .. "2"]:SetText("??h ??m");
					if (challenge.removed == true) then
						content["info" .. i .. "2"]:SetText(const.locale["_EXPIRED"]);
						content["info" .. i .. "2"]:SetTextColor(0.5,0.5,0.5);
					elseif (challenge.ended == true) then
						content["info" .. i .. "2"]:SetFormattedText("%dh %dm", Peggle.TimeBreakdown(challenge.elapsed));
						content["info" .. i .. "2"]:SetTextColor(0.5, 0.5, 0.5);
					else
						hours, minutes = Peggle.TimeBreakdown(challenge.elapsed);
						content["info" .. i .. "2"]:SetFormattedText("%dh %dm", hours, minutes);
						if (hours < 2) then
							content["info" .. i .. "2"]:SetTextColor(1, 0, 0);
						elseif (hours < 8) then
							content["info" .. i .. "2"]:SetTextColor(1, 1, 0);
						else
							content["info" .. i .. "2"]:SetTextColor(0, 1, 0);
						end
					end

				else
					content["info" .. i .. "1"]:SetText("");
					content["info" .. i .. "2"]:SetText("");
				end
			end
		elseif (self.state == 1) then
--[[			
			challenge = challengeGroup[self.showID];
			self.extraInfo = challenge;
			local nameList = challenge[infoList[2] ];
			content.listSlider:SetMinMaxValues(0, max(0, #nameList - 13));
			if (content.listSlider:GetValue() > (max(0, (#nameList - 13)))) then
				content.listSlider:SetValue(max(0, #nameList - 13));
			end

			GetChallenge(challenge);
			local view = const.currentView;
			local offset = content.listSlider:GetValue();
			local id, power, redFlag, blueFlag, value;
			for i = 1, 13 do
				id = i + offset
				name = nameList[id];
				if (name) then
					content["info" .. i .. "1"]:SetText(name);
					if (view[8][id] > 1000) then
						value = view[8][id] - 1;
						redFlag = mod(value, 100);
						value = (value - redFlag) / 100;
						if (value >= 30) then
							blueFlag = value - 30;
							power = 2;
						else
							blueFlag = value - 10;
							power = 1;
						end
						if (redFlag == 0) then
							redFlag = "";
						end
						if (blueFlag == 0) then
							blueFlag = "";
						end

						content["info" .. i .. "2"]:SetText(NumberWithCommas(view[7][id]));
						content["info" .. i .. "1"]:SetTextColor(1,1,1);
						content["info" .. i .. "2"]:SetTextColor(1,1,1);
						content["info" .. i .. "a"]:SetTexture(const.artPath .. "char" .. power .. "Power");
						content["info" .. i .. "b1"]:SetText(redFlag);
						content["info" .. i .. "c1"]:SetText(blueFlag);
						content["info" .. i .. "a"]:Show();
						content["info" .. i .. "b"]:Show();
						content["info" .. i .. "c"]:Show();
						content["info" .. i .. "b1"]:Show();
						content["info" .. i .. "c1"]:Show();
					else
						content["info" .. i .. "2"]:SetText(0);
						content["info" .. i .. "1"]:SetTextColor(0.5,0.5,0.5);
						content["info" .. i .. "2"]:SetTextColor(0.5,0.5,0.5);
						content["info" .. i .. "a"]:Hide();
						content["info" .. i .. "b"]:Hide();
						content["info" .. i .. "c"]:Hide();
						content["info" .. i .. "b1"]:Hide();
						content["info" .. i .. "c1"]:Hide();
					end
				else
					content["info" .. i .. "1"]:SetText("");
					content["info" .. i .. "2"]:SetText("");
					content["info" .. i .. "a"]:Hide();
					content["info" .. i .. "b"]:Hide();
					content["info" .. i .. "c"]:Hide();
					content["info" .. i .. "b1"]:Hide();
					content["info" .. i .. "c1"]:Hide();
				end
			end

			content.stageInfo1a:SetFormattedText(string.format("%d - %s", view[3], const.locale["LEVEL_NAME" .. view[3] ]));
			content.stageInfo2a:SetText(view[4])
--			content.stageInfo3a:SetText(view[5]);
			content.stageInfo4a:SetText(view[6]);
			content.levelImage.tex:SetTexture(const.artPath .. "bg" .. view[3] .. "_thumb");
			content.timeLeft:SetText("??h ??m"); --view[2];

			if (challenge.removed == true) then
				content.timeLeft:SetText(const.locale["_EXPIRED"]);
				content.timeLeft:SetTextColor(0.5,0.5,0.5);
				SetDesaturation(content.startChallenge.background, true);
				content.startChallenge:EnableMouse(false);
			elseif (challenge.ended == true) then
				content.timeLeft:SetFormattedText("%dh %dm", Peggle.TimeBreakdown(challenge.elapsed));
				content.timeLeft:SetTextColor(0.5, 0.5, 0.5);
				SetDesaturation(content.startChallenge.background, true);
				content.startChallenge:EnableMouse(false);
			else
				hours, minutes = Peggle.TimeBreakdown(challenge.elapsed);
				content.timeLeft:SetFormattedText("%dh %dm", hours, minutes);
				if (hours < 2) then
					content.timeLeft:SetTextColor(1, 0, 0);
				elseif (hours < 8) then
					content.timeLeft:SetTextColor(1, 1, 0);
				else
					content.timeLeft:SetTextColor(0, 1, 0);
				end
				id = Peggle.TableFind(nameList, const.name);
				if (view[7][id] == -1) then
					SetDesaturation(content.startChallenge.background, false);
					content.startChallenge:EnableMouse(true);
				else
					SetDesaturation(content.startChallenge.background, true);
					content.startChallenge:EnableMouse(false);
				end
			end

			content.challenger:SetText(view[1]);
--]]
		end

		if (self.state == 2) then
			
			challenge = challengeGroup[self.showID];
			self.extraInfo = challenge;
			local nameList = challenge[infoList[2]];

			GetChallenge(challenge);
			local view = const.currentView;
			local offset = content.nameListSlider:GetValue();
			local id, power, redFlag, blueFlag, value;

			self.tempNames = self.tempNames or {};
			local names = self.tempNames;

			self.nameListSlider:SetMinMaxValues(0, max(#nameList - 13, 0));

			-- Rebuild our name list, with ranks and stuff
			if (dirty) then
				table.wipe(names);

				local name, score, i
				i = 1;
				for i = 1, #nameList do 
					names[i] = {nameList[i], view[7][i], i, view[8][i]};
				end
				table.sort(names, window.peggleLootTimer.compare);

--				for i = 1, #names do 
--					if (names[i][2] > -1) then
--						window.network:Chat(i .. " - " .. names[i][1] .. " - " .. NumberWithCommas(names[i][2]) .. " pts", channel);
--					else
---						window.network:Chat(i .. " - " .. names[i][1] .. " - " .. DECLINE, channel);
---					end
--				end
				
			end

			local rank = 1;
			for i = 1, 13 do
				id = i + offset
				rank = id;
--				name = nameList[id];
				if (names[id]) then
					
					id = names[id][3];
					name = nameList[id];
	--			if (name) then
					content["infoName" .. i .. "1"]:SetText(name);
					if (view[8][id] and view[8][id] > 1000) then
						value = view[8][id] - 1;
						redFlag = mod(value, 100);
						value = (value - redFlag) / 100;
						if (value >= 30) then
							blueFlag = value - 30;
							power = 2;
						else
							blueFlag = value - 10;
							power = 1;
						end
						if (redFlag == 0) then
							redFlag = "";
						end
						if (blueFlag == 0) then
							blueFlag = "";
						end
--						content["infoName" .. i .. "1"]:SetPoint("Topleft", 66,  -10 - (i - 1) * 20);
						content["infoName" .. i .. "2"]:SetText(NumberWithCommas(view[7][id]));
						content["infoRank" .. i]:SetText(rank);
						content["infoName" .. i .. "1"]:SetTextColor(1,1,1);
						content["infoName" .. i .. "2"]:SetTextColor(1,1,1);
						content["infoName" .. i .. "a"]:SetTexture(const.artPath .. "char" .. power .. "Power");
						content["infoName" .. i .. "b1"]:SetText(redFlag);
						content["infoName" .. i .. "c1"]:SetText(blueFlag);
						content["infoName" .. i .. "a"]:Show();
						content["infoName" .. i .. "b"]:Show();
						content["infoName" .. i .. "c"]:Show();
						content["infoName" .. i .. "b1"]:Show();
						content["infoName" .. i .. "c1"]:Show();
					else
--						content["infoName" .. i .. "1"]:SetPoint("Topleft", 10,  -10 - (i - 1) * 20);
						content["infoName" .. i .. "2"]:SetText(0);
						content["infoRank" .. i]:SetText("");
						content["infoName" .. i .. "1"]:SetTextColor(0.5,0.5,0.5);
						content["infoName" .. i .. "2"]:SetTextColor(0.5,0.5,0.5);
						content["infoName" .. i .. "a"]:Hide();
						content["infoName" .. i .. "b"]:Hide();
						content["infoName" .. i .. "c"]:Hide();
						content["infoName" .. i .. "b1"]:Hide();
						content["infoName" .. i .. "c1"]:Hide();
					end
				else
					content["infoName" .. i .. "1"]:SetText("");
					content["infoName" .. i .. "2"]:SetText("");
					content["infoRank" .. i]:SetText("");
					content["infoName" .. i .. "a"]:Hide();
					content["infoName" .. i .. "b"]:Hide();
					content["infoName" .. i .. "c"]:Hide();
					content["infoName" .. i .. "b1"]:Hide();
					content["infoName" .. i .. "c1"]:Hide();
				end
			end

			content.stageDetails1a:SetText(view[1]);
			if (challenge.removed == true) then
				content.stageDetails2a:SetText(const.locale["_EXPIRED"]);
				content.stageDetails2a:SetTextColor(0.5,0.5,0.5);
				SetDesaturation(content.startChallenge1.background, true);
				content.startChallenge1:EnableMouse(false);
			elseif (challenge.ended == true) then
				content.stageDetails2a:SetFormattedText("%dh %dm", Peggle.TimeBreakdown(challenge.elapsed));
				content.stageDetails2a:SetTextColor(0.5, 0.5, 0.5);
				SetDesaturation(content.startChallenge1.background, true);
				content.startChallenge1:EnableMouse(false);
			else
				hours, minutes = Peggle.TimeBreakdown(challenge.elapsed);
				content.stageDetails2a:SetFormattedText("%dh %dm", hours, minutes);
				if (hours < 2) then
					content.stageDetails2a:SetTextColor(1, 0, 0);
				elseif (hours < 8) then
					content.stageDetails2a:SetTextColor(1, 1, 0);
				else
					content.stageDetails2a:SetTextColor(0, 1, 0);
				end
				SetDesaturation(content.startChallenge1.background, false);
				content.startChallenge1:EnableMouse(true);
			end

			content.stageDetails3a:SetText(view[4])
			content.stageDetails4a:SetText(view[6]);
			content.levelImage1.tex:SetTexture(const.artPath .. "bg" .. view[3] .. "_thumb");

			-- Find leader score
			local myRank = 0;
			local totalRank = 0;

			local bestScore = 0;
			local name = NONE;
			local myScore = 0;

			id = Peggle.TableFind(nameList, const.name);
			myScore = view[7][id];
			--printd(id);
			--printd(myScore);
			--printd(view[8][id]);
			if (myScore > -1) then
				for i = 1, #nameList do
					if (view[7][i] > -1) then
						totalRank = totalRank + 1;
						if (i ~= id) then
							if (view[7][i] < myScore) then
								myRank = myRank + 1;
							end
						end
					end
					if (view[7][i] > bestScore) then
						bestScore = view[7][i];
						name = i; --nameList[i];
					end
				end
			end
			myRank = totalRank - myRank;

--			content.stageDetails5a:SetText(name);

			-- Find player score
--			id = Peggle.TableFind(nameList, const.name);
			if (myScore == -1) then
				content.stageDetails6a:SetText(content.stageDetails6a.caption1);
				SetDesaturation(content.startChallenge1.background, false);
				content.startChallenge1:EnableMouse(true);
			else
				content.stageDetails6a:SetFormattedText(content.stageDetails6a.caption2, myRank, totalRank);
				SetDesaturation(content.startChallenge1.background, true);
				content.startChallenge1:EnableMouse(false);
			end

		end
				
	end

		local text = Peggle:CreateCaption(0, 0, const.locale["CHALLENGE"], content, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", 0, -22);
		text.caption1 = text:GetText();
		text.caption2 = const.locale["CHALLENGE_DETAILS"];
		content.title = text;
--===============
--		text = Peggle:CreateCaption(0, 0, const.locale["CHALLENGE_DESC"], content, 18, 1, 0.55, 0, 1, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Top", 0, -72);
--		content.desc = text;

		local listBorder = CreateFrame("Frame", "", content);
		listBorder:SetPoint("Topleft", 10, -58)
		listBorder:SetPoint("Bottomleft", 10, 10);
		listBorder:SetWidth(200);
		windowBackdrop.bgFile = const.artPath .. "windowBackground";
		windowBackdrop.tileSize = 128;
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0.4,0.4,0.4,1);
		listBorder:SetBackdropBorderColor(1,1,1);

		listBorder = CreateFrame("Frame", "", listBorder);
		listBorder:SetPoint("Topleft", 6, -30)
		listBorder:SetPoint("Bottomright", -6, 6 + 66);
--		listBorder:SetWidth(300);
		windowBackdrop.bgFile = const.artPath .. "windowBackground";
		windowBackdrop.tileSize = 128;
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0.2,0.2,0.2,1);
		listBorder:SetBackdropBorderColor(1,1,1);

		local slider = CreateFrame("Slider", "Peggle_challengeListSlider", listBorder, "UIPanelScrollBarTemplate");
		slider:SetPoint("TopRight", listBorder, "TopRight", -6, -21);
		slider:SetPoint("BottomRight", listBorder, "BottomRight", -6, 23);
		slider:SetValueStep(1);
		slider:SetMinMaxValues(0, 0);
		slider:SetScript("OnValueChanged", function () end);
		slider:SetValue(0);
		slider:SetScript("OnValueChanged", function (self)
			window.catagoryScreen.frames[3].content1:UpdateScreen()
		end);
--		getglobal(slider:GetName() .. "ThumbTexture"):Hide();
		slider.background = slider:CreateTexture(nil, "background");
		slider.background:SetPoint("TopLeft")
		slider.background:SetPoint("BottomRight", -1, 0)
		slider.background:SetTexture(0, 0, 0, 0.35);
		getglobal(slider:GetName() .. "ScrollUpButton"):SetScript("OnClick",
		function (self)
			self:GetParent():SetValue(self:GetParent():GetValue() - 1);
		end);
		getglobal(slider:GetName() .. "ScrollDownButton"):SetScript("OnClick",
		function (self)
			self:GetParent():SetValue(self:GetParent():GetValue() + 1);
		end);
		content.listSlider = slider;

--		local xPos = {10, 140, 175, 236, 310, 395, 510};

		text = Peggle:CreateCaption(20, 138, const.locale["CHALLENGE_LIST"], listBorder, 16, 1, 1, 0, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", listBorder:GetParent(), "Top", 0, -10);
		text:SetWidth(180);
		text.caption1 = text:GetText();
		text.caption2 = const.locale["CHALLENGE_PLAYER"]
		content.catagory1 = text;

		local challengeOnEnter = function (self)
			local content = window.catagoryScreen.frames[3].content1
			local name = content["info" .. self:GetID() .. "1"]:GetText();
			local id = self:GetID() + content.listSlider:GetValue();
			if name and (name ~= "") then
				if (content.showID ~= id) then
					self.tex:SetAlpha(0.5);
				end
			end
		end

		local challengeOnLeave = function (self)
			local content = window.catagoryScreen.frames[3].content1
			local id = self:GetID() + content.listSlider:GetValue();
			if (content.showID ~= id) then
				self.tex:SetAlpha(0);
			end
		end

		local challengeOnMouseWheel = function (self, direction)
			local content = window.catagoryScreen.frames[3].content1;
			content.listSlider:SetValue(content.listSlider:GetValue() - (direction * 3));
		end

		local challengeOnClick = function (self)
			local content = window.catagoryScreen.frames[3].content1;
			local name = content["info" .. self:GetID() .. "1"]:GetText();
			local id = self:GetID() + content.listSlider:GetValue();
			if name and (name ~= "")  then
				if (content.showID ~= id) then
					local i;
					for i = 1, 13 do 
						content["highlight" .. i].tex:SetAlpha(0);
					end
					self.tex:SetAlpha(1);
					content.showID = id;
					content.state = 2;
					playerChallenges[content.showID].new = nil;
					content:Hide();
					content:Show();
				end
			end

		end

		local i, tex;
		for i = 1, 13 do 
			--66
			text = Peggle:CreateCaption(10, 10 + (i - 1) * 20, "nameGoesHere", listBorder, 11, 1, 1, 1, nil, nil)
			text:ClearAllPoints();
			text:SetPoint("Topleft", 10,  -10 - (i - 1) * 20);
			text:SetWidth(100);
			text:SetHeight(14);
			text:SetJustifyH("LEFT");
			content["info" .. i .. "1"] = text;

			text = Peggle:CreateCaption(170, 10 + (i - 1) * 20, "48h 44m", listBorder, 11, 1, 1, 1, nil, nil)
			text:ClearAllPoints();
			text:SetPoint("Topright", -22, -10 - (i - 1) * 20);
			text:SetWidth(90);
			text:SetHeight(14);
			text:SetJustifyH("RIGHT");
			content["info" .. i .. "2"] = text;

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(32);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", -14, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "new");
			content["info" .. i .. "New"] = tex;
			tex:Hide();

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", -8, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "checkmark");
			content["info" .. i .. "Played"] = tex;
			tex:Hide();

--[[
			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", 14, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "char1Power");
			content["info" .. i .. "a"] = tex;

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", 30, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "bannerSmallRed");
			content["info" .. i .. "b"] = tex;
			text = Peggle:CreateCaption(30, 10 + (i - 1) * 20, "12", listBorder, 9, 1, 1, 1, 1, nil)
			text:SetWidth(18);
			text:SetHeight(14);
			content["info" .. i .. "b1"] = text;

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", 46, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "bannerSmallBlue");
			content["info" .. i .. "c"] = tex;
			text = Peggle:CreateCaption(46, 10 + (i - 1) * 20, "8", listBorder, 9, 1, 1, 1, 1, nil)
			text:SetWidth(18);
			text:SetHeight(14);
			content["info" .. i .. "c1"] = text;
--]]
			obj = CreateFrame("Frame", "", listBorder);
			obj:SetWidth(156);
			obj:SetHeight(20);
			obj:SetPoint("Topleft", 10, - 8 - (i - 1) * 20);
			obj:SetScript("OnEnter", challengeOnEnter);
			obj:SetScript("OnLeave", challengeOnLeave);
			obj:SetScript("OnMouseUp", challengeOnClick);
			obj:SetScript("OnMouseWheel", challengeOnMouseWheel);
			obj.tex = listBorder:CreateTexture(nil, "Artwork");
			obj.tex:SetAllPoints(obj);
			obj.tex:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
			obj.tex:SetVertexColor(0.1,0.75,1);
			obj.tex:SetAlpha(0);
			obj.tex:SetBlendMode("ADD");
			obj:EnableMouse(true);
			obj:EnableMouseWheel(true);
			obj:SetID(i);
			content["highlight" .. i] = obj;

		end

		obj = CreateButton(0, 0, 36, "buttonNewChallenge", nil, "newChallengeButton", listBorder:GetParent(), function (self)
			local frame = window.catagoryScreen.frames[3];
			frame.content1:Hide();
			table.wipe(frame.content2.inviteList);
			tinsert(frame.content2.inviteList, const.name);
			frame.content2.active = true;
			frame.content2.nameSlider:SetValue(0);
			frame.content2.setSrc = 0;
			frame.content2.inviteBox:GetScript("OnClick")(frame.content2.inviteBox);
			frame.content2.invitedCount:SetFormattedText(frame.content2.invitedCount.caption, 1);
			frame.content2.inviteSlider:SetValue(0);
			frame.content2.inviteSlider:SetMinMaxValues(0, 0);
			frame.content2.inviteSlider:GetScript("OnValueChanged")(frame.content2.inviteSlider);
			frame.content2:Show();
--[[
			frame.content1.state = 1;
			frame.content1:Hide();
			frame.content1:Show();
--]]
		end)
		obj:ClearAllPoints();
		obj:SetPoint("Bottom", 0, 34);
		content.newChallenge = obj;

		text = Peggle:CreateCaption(20, 138, const.locale["CHALLENGE_LIMIT"], listBorder:GetParent(), 10, 1, 1, 1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Bottom", listBorder:GetParent(), "Bottom", 0, 10);
		text:SetWidth(180);
--		content.catagory1 = text;

	-- Challenge quick-look screen
	-- ========================================================

	-- This will be state 2 (state 0 is just the list of challenges) for first screen, since
	-- a lot of stuff is being shared between the two

		listBorder = CreateFrame("Frame", "", content);
		listBorder:SetPoint("Topleft", 10 + 200, -58)
		listBorder:SetPoint("Bottomright", -10, 10);
		listBorder:SetWidth(200);
		windowBackdrop.bgFile = const.artPath .. "windowBackground";
		windowBackdrop.tileSize = 128;
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0.4,0.4,0.4,1);
		listBorder:SetBackdropBorderColor(1,1,1);

		text = Peggle:CreateCaption(190, 138, const.locale["CHALLENGE_DETAILS"], listBorder, 16, 1, 1, 0, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", listBorder, "Top", 0, -10);
		text:SetWidth(180);
		content.details = text;

		text = Peggle:CreateCaption(0, 0, const.locale["CHALLENGE_DESC"], listBorder, 18, 1, 0.55, 0, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Center");
		content.noneSelected = text;

		local locY = 30;

		text = Peggle:CreateCaption(12, locY, const.locale["CHALLENGE_CAT1"], listBorder, 12, 1, 1, 0, nil, nil)
		content.stageDetails1 = text;
		text = Peggle:CreateCaption(62, locY, "nameGoesHere", listBorder, 12, 1, 1, 1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Topright", listBorder, "Topleft", 10 + 128, -locY);
		text:SetJustifyH("RIGHT");
		content.stageDetails1a = text;
		locY = locY + 16;

		text = Peggle:CreateCaption(12, locY, const.locale["CHALLENGE_CAT5"], listBorder, 12, 1, 1, 0, nil, nil)
		content.stageDetails2 = text;
		text = Peggle:CreateCaption(82, locY, "47h 59m", listBorder, 12, 1, 1, 1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Topright", listBorder, "Topleft", 10 + 128, -locY);
		text:SetJustifyH("RIGHT");
		content.stageDetails2a = text;
		locY = locY + 16;

		text = Peggle:CreateCaption(12, locY, const.locale["CHALLENGE_CAT3"], listBorder, 12, 1, 1, 0, nil, nil)
		content.stageDetails3 = text;
		text = Peggle:CreateCaption(82, locY, "0", listBorder, 12, 1, 1, 1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Topright", listBorder, "Topleft", 10 + 128, -locY);
		text:SetJustifyH("RIGHT");
		content.stageDetails3a = text;
		locY = locY + 16;

		text = Peggle:CreateCaption(12, locY, const.locale["CHALLENGE_CAT2"], listBorder, 12, 1, 1, 0, nil, nil)
		content.stageDetails5 = text;
		text:SetText("");
--		locY = locY + 16;
		text = Peggle:CreateCaption(12, locY, "", listBorder, 12, 1, 1, 1, nil, nil)
		content.stageDetails5a = text;
--		locY = locY + 16;

		obj = CreateFrame("Frame", "", listBorder);
		obj:SetPoint("Topleft", 10, -locY)
		obj:SetWidth(128) -- + 32);
		obj:SetHeight(128) -- + 32);
		obj:SetBackdrop(windowBackdrop);
		obj:SetBackdropColor(0,0,0,0);
		obj:SetBackdropBorderColor(1,1,1);
		content.levelImage1 = obj;

		tex = obj:CreateTexture(nil, "Background");
		tex:SetTexture(const.artPath .. "bg1_thumb");
		tex:SetPoint("Center");
		tex:SetWidth(128 - 14) -- + 32);
		tex:SetHeight(128 - 14) -- + 32);
		obj.tex = tex;

		locY = locY + obj:GetHeight();

		text = Peggle:CreateCaption(12, locY, const.locale["CHALLENGE_CAT6"], listBorder, 12, 1, 1, 0, nil, nil)
		content.stageDetails4 = text;
		locY = locY + 16;
		text = Peggle:CreateCaption(12, locY, "", listBorder, 12, 1, 1, 1, nil, nil)
		text:SetWidth(128);
		text:SetHeight(13*4);
		text:SetJustifyH("LEFT");
		text:SetJustifyV("TOP");
		content.stageDetails4a = text;
		locY = locY + 13*4 + 4;

		text = Peggle:CreateCaption(12, locY , const.locale["CHALLENGE_CAT4"], listBorder, 12, 1, 1, 0, nil, nil)
		content.stageDetails6 = text;
		locY = locY + 16;
		text = Peggle:CreateCaption(12, locY, const.locale["NOT_PLAYED"], listBorder, 12, 1, 1, 1, nil, nil)
		text.caption1 = text:GetText();
		text.caption2 = const.locale["CHALLENGE_RANK"];
		content.stageDetails6a = text;

--[[
		obj = CreateButton(0, 0, 30, "buttonView", true, "viewChallengeButton", listBorder, function (self)
			local frame = window.catagoryScreen.frames[3];
			frame.content1.state = 1;
			frame.content1:Hide();
			frame.content1:Show();
		end)
		obj:ClearAllPoints();
		obj:SetPoint("Center", 50, -128);
		content.viewChallenge = obj;
--]]
		obj = CreateButton(0, 0, 40, "buttonGo", nil, "startChallengeButton1", listBorder, function (self)
			local frame = window.catagoryScreen.frames[3];
			local levelID = const.currentView[3];
			local challenge = frame.content1.extraInfo
			frame.content1.state = 2;
			frame.content1:Hide();
			frame.content1:Show();

			Generate(levelString[levelID], challenge);
			ShowGameUI(true);
			shooterReady = false;

		end)
		obj:ClearAllPoints();
		obj:SetPoint("Bottom", -75, 21);
		content.startChallenge1 = obj;

		obj = CreateButton(0, 0, 40, "buttonBack", nil, "backChallengeButton", listBorder, function (self)
			local frame = window.catagoryScreen.frames[3];
			frame.content1.state = 0;
			frame.content1:Hide();
			frame.content1:Show();
		end, nil, true)
		obj:ClearAllPoints();
		obj:SetPoint("Bottom", 75, 21);
		content.backChallenge = obj;

		listBorder = CreateFrame("Frame", "", listBorder);
		listBorder:SetPoint("Topright", -6, -30)
		listBorder:SetPoint("Bottomright", -6, 6 + 66);
		listBorder:SetWidth(270);
		windowBackdrop.bgFile = const.artPath .. "windowBackground";
		windowBackdrop.tileSize = 128;
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0.2,0.2,0.2,1);
		listBorder:SetBackdropBorderColor(1,1,1);
		content.nameList = listBorder;

		listBorder:EnableMouseWheel(true)
		listBorder:SetScript("OnMouseWheel", function (self, direction)
			content = window.catagoryScreen.frames[3].content1;
			content.nameListSlider:SetValue(content.nameListSlider:GetValue() - (direction * 3));
		end);

		local slider = CreateFrame("Slider", "Peggle_challengeNameListSlider", listBorder, "UIPanelScrollBarTemplate");
		slider:SetPoint("TopRight", listBorder, "TopRight", -6, -21);
		slider:SetPoint("BottomRight", listBorder, "BottomRight", -6, 23);
		slider:SetValueStep(1);
		slider:SetMinMaxValues(0, 0);
		slider:SetScript("OnValueChanged", function () end);
		slider:SetValue(0);
		slider:SetScript("OnValueChanged", function (self)
			window.catagoryScreen.frames[3].content1:UpdateScreen()
		end);

		slider.background = slider:CreateTexture(nil, "background");
		slider.background:SetPoint("TopLeft")
		slider.background:SetPoint("BottomRight", -1, 0)
		slider.background:SetTexture(0, 0, 0, 0.35);
		getglobal(slider:GetName() .. "ScrollUpButton"):SetScript("OnClick",
		function (self)
			self:GetParent():SetValue(self:GetParent():GetValue() - 1);
		end);
		getglobal(slider:GetName() .. "ScrollDownButton"):SetScript("OnClick",
		function (self)
			self:GetParent():SetValue(self:GetParent():GetValue() + 1);
		end);
		content.nameListSlider = slider;

--		local xPos = {10, 140, 175, 236, 310, 395, 510};

--		local challengeOnEnter = function (self)
--			local content = window.catagoryScreen.frames[3].content1
--			if (content.state ~= 1) then
--				local name = content["info" .. self:GetID() .. "1"]:GetText();
--				if name and (name ~= "") then
--					self.tex:SetAlpha(0.25);
--				end
--			end
--		end

--		local challengeOnLeave = function (self)
--			self.tex:SetAlpha(0);
--		end

--[[
		local challengeOnClick = function (self)
			content = window.catagoryScreen.frames[3].content1;
			if (content.state ~= 1) then
				name = content["info" .. self:GetID() .. "1"]:GetText();
				if name and (name ~= "")  then
					content.showID = self:GetID() + content.listSlider:GetValue();
					content.state = 1;
--			frame.content1.state = 1;
--			frame.content1:Hide();
--			frame.content1:Show();

					content:Hide();
					content:Show();
				end
			end
		end
--]]
		local i, tex;
		for i = 1, 13 do 
			--66
			text = Peggle:CreateCaption(10, 66 + (i - 1) * 20, i, listBorder, 11, 1, 1, 1, nil, nil)
			text:ClearAllPoints();
			text:SetPoint("Topleft", 12,  -10 - (i - 1) * 20);
			text:SetWidth(24);
			text:SetHeight(14);
			text:SetJustifyH("LEFT");
			content["infoRank" .. i] = text;

			text = Peggle:CreateCaption(10, 66 + (i - 1) * 20, "nameGoesHereSomeMore", listBorder, 11, 1, 1, 1, nil, nil)
			text:ClearAllPoints();
			text:SetPoint("Topleft", 32,  -10 - (i - 1) * 20);
			text:SetWidth(100);
			text:SetHeight(14);
			text:SetJustifyH("LEFT");
			content["infoName" .. i .. "1"] = text;

			text = Peggle:CreateCaption(170, 10 + (i - 1) * 20, "9,999,999", listBorder, 11, 1, 1, 1, nil, nil)
			text:ClearAllPoints();
			text:SetPoint("Topright", -24, -10 - (i - 1) * 20);
			text:SetWidth(80);
			text:SetHeight(14);
			text:SetJustifyH("RIGHT");
			content["infoName" .. i .. "2"] = text;

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", 122 + 14, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "char1Power");
			content["infoName" .. i .. "a"] = tex;

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", 122 + 30, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "bannerSmallRed");
			content["infoName" .. i .. "b"] = tex;
			text = Peggle:CreateCaption(122 + 30, 10 + (i - 1) * 20, "12", listBorder, 9, 1, 1, 1, 1, nil)
			text:SetWidth(18);
			text:SetHeight(14);
			content["infoName" .. i .. "b1"] = text;

			tex = listBorder:CreateTexture(nil, "Artwork");
			tex:SetWidth(16);
			tex:SetHeight(16);
			tex:SetPoint("Topleft", 122 + 46, -9 - (i - 1) * 20);
			tex:SetTexture(const.artPath .. "bannerSmallBlue");
			content["infoName" .. i .. "c"] = tex;
			text = Peggle:CreateCaption(122 + 46, 10 + (i - 1) * 20, "8", listBorder, 9, 1, 1, 1, 1, nil)
			text:SetWidth(18);
			text:SetHeight(14);
			content["infoName" .. i .. "c1"] = text;
--[[
			obj = CreateFrame("Frame", "", listBorder);
			obj:SetWidth(156);
			obj:SetHeight(20);
			obj:SetPoint("Topleft", 10, - 8 - (i - 1) * 20);
--			obj:SetScript("OnEnter", challengeOnEnter);
--			obj:SetScript("OnLeave", challengeOnLeave);
--			obj:SetScript("OnMouseUp", challengeOnClick);
			obj:SetScript("OnMouseWheel", challengeOnMouseWheel);
--			obj.tex = listBorder:CreateTexture(nil, "Artwork");
--			obj.tex:SetAllPoints(obj);
--			obj.tex:SetTexture(1, 1, 0);
--			obj.tex:SetAlpha(0);
			obj:EnableMouse(true);
			obj:EnableMouseWheel(true);
--			obj:SetID(i);
--]]
		end

	-- Challenge view screen
	-- ========================================================

	-- This will be state 1 (state 0 is just the list of challenges) for first screen, since
	-- a lot of stuff is being shared between the two

--		text = Peggle:CreateCaption(0, 0, const.locale["CHALLENGE_CAT1"], content, 14, 1, 1, 0, 1, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Top", content, "Topleft", 100, -72);
--		content.challengerCaption = text;

--		text = Peggle:CreateCaption(0, 0, "nameGoesHere", content, 16, 1, 1, 1, nil, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Top", content, "Topleft", 100, -90);
--		content.challenger = text;

--		text = Peggle:CreateCaption(0, 0, const.locale["CHALLENGE_CAT5"], content, 14, 1, 1, 0, 1, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Top", content, "Topleft", 240, -72);
--		content.timeLeftCaption = text;

--		text = Peggle:CreateCaption(0, 0, "47h 59m", content, 16, 1, 1, 1, nil, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Top", content, "Topleft", 240, -90);
--		content.timeLeft = text;

--		obj = CreateFrame("Frame", "", content);
--		obj:SetPoint("Topright", -90, -70)
--		obj:SetWidth(160) -- + 32);
--		obj:SetHeight(160) -- + 32);
--		obj:SetBackdrop(windowBackdrop);
--		obj:SetBackdropColor(0,0,0,0);
--		obj:SetBackdropBorderColor(1,1,1);
--		content.levelImage = obj;

--		tex = obj:CreateTexture(nil, "Background");
--		tex:SetTexture(const.artPath .. "bg1_thumb");
--		tex:SetPoint("Center");
--		tex:SetWidth(160 - 14) -- + 32);
--		tex:SetHeight(160 - 14) -- + 32);
--		obj.tex = tex;

--		text = Peggle:CreateCaption(350, 240, const.locale["CHALLENGE_CAT2"], content, 16, 1, 1, 0, nil, nil)
--		content.stageInfo1 = text;
--		text = Peggle:CreateCaption(350, 260, const.locale["CHALLENGE_CAT3"], content, 16, 1, 1, 0, nil, nil)
--		content.stageInfo2 = text;
--		text = Peggle:CreateCaption(350, 280, const.locale["CHALLENGE_CAT4"], content, 16, 1, 1, 0, nil, nil)
--		content.stageInfo3 = text;
--		text = Peggle:CreateCaption(440, 290, const.locale["CHALLENGE_CAT6"], content, 16, 1, 1, 0, nil, nil)
--		content.stageInfo4 = text;

--		text = Peggle:CreateCaption(400, 240, string.format("%d - %s", 1, const.locale["LEVEL_NAME" .. 1]), content, 16, 1, 1, 1, nil, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Topright", -30, -240);
--		text:SetWidth(220);
--		text:SetJustifyH("RIGHT");
--		content.stageInfo1a = text;
--		text = Peggle:CreateCaption(430, 260, "10", content, 16, 1, 1, 1, nil, nil)
--		text:ClearAllPoints();
--		text:SetPoint("Topright", -30, -260);
--		text:SetWidth(160);
--		text:SetJustifyH("RIGHT");
--		content.stageInfo2a = text;
--[[
		text = Peggle:CreateCaption(430, 280, "1", content, 16, 1, 1, 1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Topright", -30, -280);
		text:SetWidth(160);
		text:SetJustifyH("RIGHT");
		content.stageInfo3a = text;
--]]
--		text = Peggle:CreateCaption(330, 307, "This is a note, and only a note. If you think it's something else, you're mistaken.", content, 16, 1, 1, 1, nil, nil)
--		text:SetWidth(270);
--		text:SetHeight(18*4); --3  327
--		text:SetJustifyV("TOP");
--		content.stageInfo4a = text;

--		obj = CreateButton(0, 0, 40, "buttonGo", nil, "startChallengeButton", content, getglobal("PeggleButton_startChallengeButton1"):GetScript("OnClick"))
--		obj:ClearAllPoints();
--		obj:SetPoint("Center", 150, -178);
--		content.startChallenge = obj;

	content:Show();

	-- Challenge creation screen
	-- ========================================================

	content = CreateFrame("Frame", "", frame);
	content:SetPoint("TopLeft")
	content:SetPoint("BottomRight");
	content:Hide();
	frame.content2 = content;
	content.setSrc = 1;
	content.setDur = 1;
	content.serverChannels = {EnumerateServerChannels()}
	content.channelNames = {};
	content.inviteList = {};
	content.grabNames = {};
	content.getChannels = function (id)
		return ("|cFF4CB2FF" .. window.catagoryScreen.frames[3].content2.channelNames[id]);
	end

		text = Peggle:CreateCaption(10, 26, const.locale["CHALLENGE_NEW"], content, 30, 0.05, 0.66, 1, 1, nil)
		text.caption1 = text:GetText();
		text.caption2 = const.locale["CHALLENGE"];
		text:SetWidth(330);

		text = Peggle:CreateCaption(10, 60, const.locale["INVITEES"], content, 25, 1, 1, 0, 1, nil)
		text:SetWidth(330);

		text = Peggle:CreateCaption(10, 90, const.locale["CHALLENGE_DESC1"], content, 11, 1, 1, 0, 1, nil)
		text:SetWidth(330);

		text = Peggle:CreateCaption(10, 90, const.locale["CHALLENGE_DESC2"], content, 11, 1, 1, 0, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Bottomleft", 10, 40);
		text:SetWidth(350);
		text:Hide();
		content.customText = text;
		
		text = Peggle:CreateCaption(10, 90, const.locale["CHALLENGE_DESC3"], content, 10, 1, 1, 1, nil, "")
		text:ClearAllPoints();
		text:SetPoint("Bottomleft", 10, 10);
		text:SetWidth(350);

		obj = CreateCheckbox(14, 342, const.locale["CHALLENGE_VIEW_OFFLINE"], "guildViewOnline", true, content, function (self)
			if (self:GetChecked()) then
				SetGuildRosterShowOffline(true);
			else
				SetGuildRosterShowOffline(false);
			end
			content.nameSlider:SetMinMaxValues(0, max(0, GetNumGuildMembers() - 15));
			local content = window.catagoryScreen.frames[3].content2;
			if (content.nameSlider:GetValue() == 0) then
				content.nameSlider:GetScript("OnValueChanged")(content.nameSlider);
			else
				content.nameSlider:SetValue(0);
			end
		end, 1, 0.82, 0, tooltipText, true)
		obj:SetHitRectInsets(0, -120, 0, 0);
		obj:SetChecked(true);
		obj:Hide();
		content.guildOption1 = obj;

		obj = CreateCheckbox(14, 362, const.locale["CHALLENGE_SORT_ONLINE"], "guildSortOnline", true, content, function (self)
			if (self:GetChecked()) then
				SortGuildRoster("online");
			else
				SortGuildRoster("name");
			end
			content.nameSlider:SetMinMaxValues(0, max(0, GetNumGuildMembers() - 15));
			local content = window.catagoryScreen.frames[3].content2;
			if (content.nameSlider:GetValue() == 0) then
				content.nameSlider:GetScript("OnValueChanged")(content.nameSlider);
			else
				content.nameSlider:SetValue(0);
			end
		end, 1, 0.82, 0, tooltipText, true)
		obj:SetHitRectInsets(0, -120, 0, 0);
		obj:Hide();
		content.guildOption2 = obj;

		local inviteUpdateFunc = function (self)
			local content = window.catagoryScreen.frames[3].content2;

			if (content.setSrc ~= self:GetID()) then
				content.setSrc = self:GetID();
				getglobal("PeggleCheckbox_inviteSrc1"):SetChecked(false);
				getglobal("PeggleCheckbox_inviteSrc2"):SetChecked(false);
				getglobal("PeggleCheckbox_inviteSrc3"):SetChecked(false);

				content.customText:Hide();
				content.guildOption1:Hide();
				content.guildOption2:Hide();
				
				-- do stuff for each invite type
				if (content.setSrc == 1) then
					content.nameSlider:SetMinMaxValues(0, max(0, GetNumFriends() - 15));
				elseif (content.setSrc == 2) then
					local totalMembers = GetNumGuildMembers();
					content.nameSlider:SetMinMaxValues(0, max(0, totalMembers - 15));
					if (totalMembers > 0) then
						-- Sort the list if it's not.
						if ((GetGuildRosterInfo(1)) > (GetGuildRosterInfo(totalMembers))) then
							SortGuildRoster("name");
						end
					end
					content.guildOption1:Show();
					content.guildOption2:Show();
				else
					local i, j, id, name
					content.serverChannels = {EnumerateServerChannels()}
					table.wipe(content.channelNames);
					for i = 1, 15 do 
						id, name = GetChannelName(i);
						if (name) then
							for j = 1, #content.serverChannels do 
								if (string.find(name, content.serverChannels[j])) then
									name = nil;
									break;
								end
							end
							if (name) then
								tinsert(content.channelNames, name)
							end
						end
					end
					content.nameSlider:SetMinMaxValues(0, 0);
					content.customText:Show();
				end
				if (content.nameSlider:GetValue() == 0) then
					content.nameSlider:GetScript("OnValueChanged")(content.nameSlider);
				else
					content.nameSlider:SetValue(0);
				end

			end
			self:SetChecked(true);
		end

		local nameListSliderFunc = function (self)
			local content = window.catagoryScreen.frames[3].content2;
			local funcToCall, totalCount;
			if (content.setSrc == 1) then
				funcToCall = GetFriendInfo;
				totalCount = GetNumFriends();
			elseif (content.setSrc == 2) then
				funcToCall = GetGuildRosterInfo;
				totalCount = GetNumGuildMembers();
			else
				funcToCall = content.getChannels;	
				totalCount = #content.channelNames;	
			end
			local i;
			local offset = self:GetValue();
			local name, online1, online2, text;
			for i = 1, 15 do 
				text = content["listItemA" .. i];
				if (i + offset) <= totalCount then
					name, _, _, _, online1, _, _, _, online2 = funcToCall(i + offset);
					text:SetText(name);
					if (content.setSrc == 1) and not online1 then
						text:SetTextColor(0.5, 0.5, 0.5);	
					elseif (content.setSrc == 2) and not online2 then
						text:SetTextColor(0.5, 0.5, 0.5);	
					else
						text:SetTextColor(1, 1, 1);
					end
				else
					text:SetText("");
				end
			end
		end

		local inviteListSliderFunc = function (self)
			local content = window.catagoryScreen.frames[3].content2;
			local totalCount = #content.inviteList;
			local i, text;
			local offset = self:GetValue();
			for i = 1, 15 do 
				text = content["listItemB" .. i];
				if (i + offset) <= totalCount then
					text:SetText(content.inviteList[i + offset]);
					text:SetTextColor(1, 1, 1);
				else
					text:SetText("");
				end
			end
		end

		obj = CreateCheckbox(13, 115, const.locale["CHALLENGE_INVITE1"], "inviteSrc1", true, content, inviteUpdateFunc, 1, 0.82, 0, tooltipText, true)
		obj:SetHitRectInsets(0, -40, 0, 0);
		obj:SetID(1);
		obj:SetChecked(true);
		content.inviteBox = obj;
		obj = CreateCheckbox(75, 115, const.locale["CHALLENGE_INVITE2"], "inviteSrc2", true, content, inviteUpdateFunc, 1, 0.82, 0, tooltipText, true)
		obj:SetHitRectInsets(0, -25, 0, 0);
		obj:SetID(2);
		obj = CreateCheckbox(123, 115, const.locale["CHALLENGE_INVITE3"], "inviteSrc3", true, content, inviteUpdateFunc, 1, 0.82, 0, tooltipText, true)
		obj:SetHitRectInsets(0, -50, 0, 0);
		obj:SetID(3);

		text = Peggle:CreateCaption(320, 115, const.locale["INVITED"], content, 12, 1, 1, 0, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Bottom", content, "Topleft", 280, -130);
		text:SetWidth(150);
		text.caption = const.locale["INVITED"];
		content.invitedCount = text;

		listBorder = CreateFrame("Frame", "", content);
		listBorder:SetPoint("Topleft", 10, -135)
		listBorder:SetWidth(160);
		listBorder:SetHeight(204);
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0,0,0,0);
		listBorder:SetBackdropBorderColor(1,1,1);

		slider = CreateFrame("Slider", "Peggle_challengeNameSlider", listBorder, "UIPanelScrollBarTemplate");
		slider:SetPoint("TopRight", listBorder, "TopRight", -6, -21);
		slider:SetPoint("BottomRight", listBorder, "BottomRight", -6, 23);
		slider:SetValueStep(1);
		slider:SetMinMaxValues(0, 0);
		slider:SetScript("OnValueChanged", nameListSliderFunc);
		slider.background = slider:CreateTexture(nil, "background");
		slider.background:SetPoint("TopLeft")
		slider.background:SetPoint("BottomRight", -1, 0)
		slider.background:SetTexture(0, 0, 0, 0.35);
		getglobal(slider:GetName() .. "ScrollUpButton"):SetScript("OnClick", getglobal("Peggle_challengeNameListSliderScrollUpButton"):GetScript("OnClick"));
		getglobal(slider:GetName() .. "ScrollDownButton"):SetScript("OnClick", getglobal("Peggle_challengeNameListSliderScrollDownButton"):GetScript("OnClick"));
		content.nameSlider = slider;

		local listOnEnter = function (self)
			local name = window.catagoryScreen.frames[3].content2["listItemA" .. self:GetID()]:GetText();
			if name and (name ~= "") then
				self.tex:SetAlpha(0.25);
			end
		end

		local listOnEnterInvite = function (self)
			local name = window.catagoryScreen.frames[3].content2["listItemB" .. self:GetID()]:GetText();
			if name and (name ~= "") then
				self.tex:SetAlpha(0.25);
			end
		end

		local listOnLeave = function (self)
			self.tex:SetAlpha(0);
		end

		local listOnMouseWheel = function (self, direction)
			content = window.catagoryScreen.frames[3].content2;
			content.nameSlider:SetValue(content.nameSlider:GetValue() - (direction * 3));
		end

		local listOnMouseWheelInvite = function (self, direction)
			content = window.catagoryScreen.frames[3].content2;
			content.inviteSlider:SetValue(content.inviteSlider:GetValue() - (direction * 3));
		end

		local listOnClick = function (self)
			content = window.catagoryScreen.frames[3].content2;
			name = content["listItemA" .. self:GetID()]:GetText();
			if name and ((name ~= "") and (name ~= "Feature Incomplete!")) then
				if Peggle.TableInsertOnce(content.inviteList, name, true) then
					content.invitedCount:SetFormattedText(content.invitedCount.caption, #content.inviteList);
					content.inviteSlider:GetScript("OnValueChanged")(content.inviteSlider); 
					slider:SetMinMaxValues(0, max(0, #content.inviteList - 15));
				end
			end
		end

		local listOnClickInvite = function (self)
			content = window.catagoryScreen.frames[3].content2;
			offset = content.inviteSlider:GetValue();
			name = content["listItemB" .. self:GetID()]:GetText();
			if name and (name ~= "") and (name ~= const.name) then
				tremove(content.inviteList, self:GetID() + offset);
				content.invitedCount:SetFormattedText(content.invitedCount.caption, #content.inviteList);
				slider:SetMinMaxValues(0, max(0, #content.inviteList - 15));
				if (content.inviteSlider:GetValue() > (max(0, (#content.inviteList - 15)))) then
					content.inviteSlider:SetValue(max(0, #content.inviteList - 15));
				else
					content.inviteSlider:GetScript("OnValueChanged")(content.inviteSlider); 
				end
			end
		end

		for i = 1, 15 do 
			text = Peggle:CreateCaption(14, 10 + (i - 1) * 12, "NameGoesHere", listBorder, 10, 1, 1, 1, nil, "")
			text:SetWidth(128);
			text:SetHeight(12);
			text:SetJustifyH("LEFT");
			content["listItemA" .. i] = text;

			obj = CreateFrame("Frame", "", listBorder);
			obj:SetWidth(126);
			obj:SetHeight(12);
			obj:SetPoint("Topleft", 10, -11 - (i - 1) * 12);
			obj:SetScript("OnEnter", listOnEnter);
			obj:SetScript("OnLeave", listOnLeave);
			obj:SetScript("OnMouseUp", listOnClick);
			obj:SetScript("OnMouseWheel", listOnMouseWheel);
			obj.tex = listBorder:CreateTexture(nil, "Artwork");
			obj.tex:SetAllPoints(obj);
			obj.tex:SetTexture(1, 1, 0);
			obj.tex:SetAlpha(0);
			obj:EnableMouse(true);
			obj:EnableMouseWheel(true);
			obj:SetID(i);
		end

		listBorder = CreateFrame("Frame", "", content);
		listBorder:SetPoint("Topleft", 200, -135)
		listBorder:SetWidth(160);
		listBorder:SetHeight(204);
		listBorder:SetBackdrop(windowBackdrop);
		listBorder:SetBackdropColor(0,0,0,0);
		listBorder:SetBackdropBorderColor(1,1,1);

		slider = CreateFrame("Slider", "Peggle_invitedNameSlider", listBorder, "UIPanelScrollBarTemplate");
		slider:SetPoint("TopRight", listBorder, "TopRight", -6, -21);
		slider:SetPoint("BottomRight", listBorder, "BottomRight", -6, 23);
		slider:SetValueStep(1);
		slider:SetMinMaxValues(0, 0);
		slider:SetScript("OnValueChanged", inviteListSliderFunc);
--		slider:SetValue(0);
		slider.background = slider:CreateTexture(nil, "background");
		slider.background:SetPoint("TopLeft")
		slider.background:SetPoint("BottomRight", -1, 0)
		slider.background:SetTexture(0, 0, 0, 0.35);
		getglobal(slider:GetName() .. "ScrollUpButton"):SetScript("OnClick", getglobal("Peggle_challengeNameListSliderScrollUpButton"):GetScript("OnClick"));
		getglobal(slider:GetName() .. "ScrollDownButton"):SetScript("OnClick", getglobal("Peggle_challengeNameListSliderScrollDownButton"):GetScript("OnClick"));
		content.inviteSlider = slider;

		for i = 1, 15 do 
			text = Peggle:CreateCaption(14, 10 + (i - 1) * 12, "NameGoesHere", listBorder, 10, 1, 1, 1, nil, "")
			text:SetWidth(128);
			text:SetHeight(12);
			text:SetJustifyH("LEFT");
			content["listItemB" .. i] = text;
			obj = CreateFrame("Frame", "", listBorder);
			obj:SetWidth(126);
			obj:SetHeight(12);
			obj:SetPoint("Topleft", 10, -11 - (i - 1) * 12);
			obj:SetScript("OnEnter", listOnEnterInvite);
			obj:SetScript("OnLeave", listOnLeave);
			obj:SetScript("OnMouseUp", listOnClickInvite);
			obj:SetScript("OnMouseWheel", listOnMouseWheelInvite);
			obj.tex = listBorder:CreateTexture(nil, "Artwork");
			obj.tex:SetAllPoints(obj);
			obj.tex:SetTexture(1, 1, 0);
			obj.tex:SetAlpha(0);
			obj:EnableMouse(true);
			obj:EnableMouseWheel(true);
			obj:SetID(i);
		end

		obj = CreateFrame("Frame", "", content);
		obj:SetPoint("Topleft", 340 + 16 + 32 - 32 + 16, -46)
		obj:SetWidth(192 + 32) -- + 32);
		obj:SetHeight(192 + 32) -- + 32);
		obj:SetBackdrop(windowBackdrop);
		obj:SetBackdropColor(0,0,0,0);
		obj:SetBackdropBorderColor(1,1,1);

		tex = obj:CreateTexture(nil, "Background");
		tex:SetTexture(const.artPath .. "bg1_thumb");
		tex:SetPoint("Center");
		tex:SetWidth(192 + 32 - 14) -- + 32);
		tex:SetHeight(192 + 32 - 14) -- + 32);
		content.levelImage = tex;

		obj = CreateDropdown(357, 16, 256 - 16, "challengeLevels", nil, nil, content, content.levelImage, nil)
		getglobal(obj:GetName() .. "Text"):ClearAllPoints();
		getglobal(obj:GetName() .. "Text"):SetPoint("Center", content, "Topleft", 360 + (256 - 16)/2, -16 - 13);
		content.info = obj;

		obj = Peggle:CreateSlider(383, -(256 + 32), 200, const.locale["CHALLENGE_SHOTS"], "challengeNumShots", content, 1, 10, 1, nil, nil, nil, nil, nil, nil, true); 
		content.shots = obj;
--		obj = Peggle:CreateSlider(383, -(256), 200, const.locale["CHALLENGE_SHOTS"], "challengeNumShots", content, 1, 10, 1, nil, nil, nil, nil, nil, nil, true); 
--		content.shots = obj;
--		obj = Peggle:CreateSlider(383, -(256 + 32), 200, const.locale["CHALLENGE_REPLAYS"], "challengeNumReplays", content, 1, 10, 1, nil, nil, nil, nil, nil, nil, true); 
--		content.replays = obj;

		local durationUpdateFunc = function (self)
			local content = self:GetParent();
			if (content.setDur ~= self:GetID()) then
				content.setDur = self:GetID();
				getglobal("PeggleCheckbox_duration1"):SetChecked(false);
				getglobal("PeggleCheckbox_duration2"):SetChecked(false);
				getglobal("PeggleCheckbox_duration3"):SetChecked(false);
			end
			self:SetChecked(true);
		end

		text = Peggle:CreateCaption(383, 256 + 52, const.locale["CHALLENGE_DUR"], content, 14, 1, 1, 0, 1, nil)
		text:SetWidth(200);
		obj = CreateCheckbox(383 + 0, 256 + 68, "12h", "duration1", true, content, durationUpdateFunc, 1, 1, 1, tooltipText)
		obj:SetHitRectInsets(0, -50, 0, 0);
		obj:SetID(1);
		obj:SetChecked(true);
		obj = CreateCheckbox(453 + 0, 256 + 68, "24h", "duration2", true, content, durationUpdateFunc, 1, 1, 1, tooltipText)
		obj:SetHitRectInsets(0, -50, 0, 0);
		obj:SetID(2);
		obj = CreateCheckbox(523 + 0, 256 + 68, "48h", "duration3", true, content, durationUpdateFunc, 1, 1, 1, tooltipText)
		obj:SetHitRectInsets(0, -50, 0, 0);
		obj:SetID(3);

		text = Peggle:CreateCaption(373, 256 + 92, const.locale["INVITE_NOTE"] .. " " ..  const.locale["OPTIONAL"], content, 14, 1, 0.82, 0, 1, nil)
		text:SetWidth(220);
		text.caption1 = text:GetText();
		text.caption2 = const.locale["INVITE_NOTE"];
		content.note1 = text;

		text = CreateTextbox(383, 256 + 106, 194, "inviteNote", content, nil, nil, nil, tooltipText)
		text:SetMaxLetters(64);
--		text:SetFontObject(window.fontObj);
		content.note2 = text;

		obj = CreateButton(0, 0, 40, "buttonChallenge", nil, "challengeButton", content, function (self)

			-- First, check to see if we have a custom channel in our name list. If so, we need to stop
			-- now and load up the channel name grabber and have that bad boy call this function later

			-- Grab all the data we need
			local content = self:GetParent();
			local namesList = content.inviteList;
			local i, j
			j = 1;
			table.wipe(content.grabNames);
			for i = 1, #namesList do 
				if (byte(namesList[j], 1) == byte("|")) then
					tinsert(content.grabNames, sub(namesList[j], 11));
					tremove(namesList, j);
				else
					j = j + 1;
				end
			end

			-- If we have channels to query, load our query window and let it do
			-- it's thing
			if (#content.grabNames > 0) then
				ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LIST", Net_ChannelNameFilter);
				content.nameGrabber.elapsed = -1;
				content.nameGrabber:Show();
				return;
			end

			local levelID = content.info.selectedValue;
			local totalShots = content.shots:GetValue();
			local totalAttempts = 1; --content.replays:GetValue();
			local timeLength = 2 ^ (content.setDur - 1) * 12 * 60 --1 * 60; for 1, 2, and 4 hours
			local note = content.note2:GetText();
			local namesList = content.inviteList;
			if (note == "") or (note == nil) then
				note = NONE;
			end

			local challenge = BuildChallenge(levelID, totalShots, totalAttempts, timeLength, namesList, note)
			tinsert(playerChallenges, challenge);

			ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Net_ChatFilter)

			-- We become the server, by default
			challenge.serverName = const.name;

			local server = window.network.server;
			challenge[const.newInfo[14]] = true;
			tinsert(server.tracking, challenge);
			tinsert(server.list, {{}, {}, {}, nil, nil});
			server:Populate(#server.list);
			if not server:IsShown() then
				server.currentID = #server.tracking;
				server.currentNode = 0;
			end
			server:Show();

			-- Send out the challenge
			for i = 1, #namesList do 
				const.onlineList[namesList[i]] = const.onlineList[namesList[i]] or 2;
				window.network:Send(const.commands[16], challenge.id, "WHISPER", namesList[i]);
			end

			window.challengeTabSparks:Show();

			content.active = nil;

			-- Bring up the challenge details screen
			local frame = window.catagoryScreen.frames[3];
			frame.content1.state = 2;
			frame.content1.showID = #playerChallenges;
			frame.content2:Hide();
			frame.content1:Hide();
			frame.content1:Show();
			getglobal("PeggleButton_startChallengeButton1"):GetScript("OnClick")();
		end)
		obj:ClearAllPoints();
		obj:SetPoint("Center", 166, -188);
		content.newChallenge = obj;

		obj = CreateFrame("Frame", "", window);
		obj:SetAllPoints(window);
		obj:EnableMouse(true);
		obj:SetFrameLevel(obj:GetFrameLevel() + 70);
		obj.elapsed = -1;
		obj.content = content;
		obj:Hide();
		obj:SetScript("OnUpdate", function (self, elapsed)
			if (self.elapsed == -1) then
				ListChannelByName(tremove(self.content.grabNames));
				self.elapsed = 0;
			end
			self.elapsed = self.elapsed + elapsed;
			if (self.elapsed > 1) then
				if (#self.content.grabNames > 0) then
					self.elapsed = -1;
				else
					self:Hide();
					ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL_LIST", Net_ChannelNameFilter);
					-- call the challenge creation button again
					self.content.newChallenge:GetScript("OnClick")(self.content.newChallenge);
				end
			end
		end);
		content.nameGrabber = obj;

		obj = CreateFrame("Frame", "", content.nameGrabber);
		obj:SetPoint("Center")
		obj:SetWidth(560);
		obj:SetHeight(64);

		windowBackdrop.tileSize = 128;
		windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
		windowBackdrop.edgeSize = 32;
		windowBackdrop.bgFile = const.artPath .. "windowBackground";

		obj:SetBackdrop(windowBackdrop);
		obj:SetBackdropColor(0.7,0.7,0.7, 1);
		obj:SetBackdropBorderColor(1,0.8,0.45);

		text = Peggle:CreateCaption(0,0, const.locale["GENERATING_NAMES"], obj, 25, 1, 0.82, 0, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Center"); --, 0, -20);

	-- Create our challenge timer tracker
	obj = CreateFrame("Frame", "", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("top");
	obj.elapsed = 0;
	obj.sElapsed = 0;
	obj:Hide();
	obj:SetScript("OnUpdate", function (self, elapsed)
		if (playerChallenges[1]) then
			self.elapsed = self.elapsed + elapsed;
			self.sElapsed = self.sElapsed + elapsed;
			if (self.elapsed >= const.seconds) then
				self.elapsed = 0;
				
				-- Update the count for all tracked challenges
				local i;
				local challengeGroup = playerChallenges;
				for i = 1, #challengeGroup do 
					challengeGroup[i].elapsed = challengeGroup[i].elapsed - 1;
					if (challengeGroup[i].elapsed <= 0) then

						local timeLength = FromBase70(sub(challengeGroup[i][DATA], 3 + 5, 3 + 6));

						-- Mark the challenge to be removed upon login
						if (challengeGroup[i].ended) then
							challengeGroup[i].removed = true;
							challengeGroup[i].elapsed = timeLength;
						else
							challengeGroup[i].ended = true	
							challengeGroup[i].elapsed = timeLength;
							if (challengeGroup[i].creator == const.name) then
								const.cCount = const.cCount - 1;
							end
						end
					end
				end

				-- If the challenge screen is up, update it for the new times
				local frame = window.catagoryScreen;
				local content = frame.frames[3].content1;
				if (frame.frames[3]:IsShown()) then
					if not (frame.frames[3].content2.active) then
						if (content:IsVisible()) then
							content:Hide();
							content:Show();
						end
					end
				end

			end
		
			-- Have server players check for people who might not have the challenge yet
			if (self.sElapsed >= 180) then --180
				local server = window.network.server;
				local cID, sendData, nameList, nameIndex, name, sendCommand
				if (server.tracking[1]) then
				--printd("Preparing to send out challenges");
--					local cID, sendData, nameList, nameIndex, name;
					sendCommand = const.commands[16];
					for cID = 1, #server.tracking do 
						sendData = server.tracking[cID].id;
						nameList = server.tracking[cID].namesWithoutChallenge;
						if not server.tracking[cID].ended then
						--printd("not ended?");
							for nameIndex = 1, #nameList do 
								name = gsub(nameList[nameIndex], "^%l", string.upper);
								window.network:Send(sendCommand, sendData, "WHISPER", name);
								--printd("Sending invite to: " .. name);
							end
						end
					end
				end
				
				-- Ping everyone for online status 
				local challengeGroup = playerChallenges
				local challenge;
				for cID = 1, #challengeGroup do 

					challenge = challengeGroup[cID];
					nameList = challenge.names;
					sendCommand = const.commands[8] -- .. "+" .. const.ping;
					for nameIndex = 1, #nameList do 
						name = gsub(nameList[nameIndex], "^%l", string.upper);
						if (name ~= const.name) then
							window.network:Send(sendCommand, "", "WHISPER", name);
						end
					end

					-- If we're checking to see who has the challenges (because we just got it)
					if (self.sChallPing) then
						self.sChallPing = nil
						sendCommand = const.commands[16];
						sendData = challenge.id;
						nameList = challenge.namesWithoutChallenge;
						for nameIndex = 1, #nameList do 
							name = gsub(nameList[nameIndex], "^%l", string.upper);
							window.network:Send(sendCommand, sendData, "WHISPER", name);
						end
					end
				end

				self.sElapsed = 0;

			end
		end
		
	end);
	window.challengeTimer = obj;

	return frame;

--[[
	["CHALLENGE"] = "CHALLENGE",
	["CHALLENGE_DESC"] = "ACCEPT AN EXISTING CHALLENGE OR CREATE A NEW CHALLENGE!",
	["CHALLENGE_CAT1"] = "CHALLENGER",
	["CHALLENGE_CAT2"] = "LVL",
	["CHALLENGE_CAT3"] = "SHOTS",
	["CHALLENGE_CAT4"] = "PLAYERS",
	["CHALLENGE_CAT5"] = "TIME LEFT",
	["CHALLENGE_CAT6"] = "NOTE",
	["CHALLENGE_DUR"] = "CHALLENGE DURATION",
	["CHALLENGE_NEW"] = "NEW CHALLENGE",

	["INVITEES"] = "INVITEES |cFFFF8C00(%s)",
	["INVITE_PERSON"] = "INVITE INDIVIDUAL:",
	["INVITE_NOTE"] = "NOTE TO INVITEES",

--]]

end

local function CreateTab_Talents()

	local obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 297, -9)
	obj:SetPoint("BottomRight", -4, 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.0,0.0,0.0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 1);
	tinsert(window.catagoryScreen.frames, obj);

	local frame = obj;
	obj:Hide();
	obj:SetScript("OnShow", Talents_UpdateDisplay);

	local text = Peggle:CreateCaption(0, 0, const.locale["TALENTS"], obj, 40, 0.05, 0.66, 1, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -20);

	text = Peggle:CreateCaption(0, 0, const.locale["TALENTS_DESC"], obj, 18, 1.0, 0.55, 0, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -62);
	text:SetWidth(obj:GetWidth() - 20);

	local tooltip = CreateFrame("Frame", "", obj);
	tooltip:SetPoint("Top", 0, -114)
	tooltip:SetWidth(obj:GetWidth() - 40);
	tooltip:SetHeight(230);
	tooltip:SetBackdrop(windowBackdrop);
	tooltip:SetBackdropColor(0.0,0.0,0.0,0.5);
	tooltip:SetBackdropBorderColor(1,1,1);
		
		local tex = tooltip:CreateTexture(nil, "Artwork");
		tex:SetWidth(64);
		tex:SetHeight(64);
		tex:SetPoint("Topleft", -10, 10);
		tex:SetTexture(const.artPath .. const.talentTex[1]);
		obj.icon = tex;
		tex:Hide();

		text = Peggle:CreateCaption(0,0,"", tooltip, 22, 1, 1, 1, 1)
		text:ClearAllPoints();
--		text:SetPoint("Top", 0, -10);
		text:SetPoint("Top", 22, -10);
		text:SetWidth(tooltip:GetWidth() - 20);
		text:Hide();
		obj.name = text;

		text = Peggle:CreateCaption(0,0,"", tooltip, 16, 1, 1, 1, nil, true)
		text:ClearAllPoints();
--		text:SetPoint("Top", 0, -30);
		text:SetPoint("Top", 22, -30);
		text:SetWidth(tooltip:GetWidth() - 20);
		text:Hide();
		obj.rank = text;

		text = Peggle:CreateCaption(0,0,"", tooltip, 14, 1, 0.82, 0, nil, true)
		text:ClearAllPoints();
		text:SetPoint("Top", 0, -54);
		text:SetJustifyH("LEFT");
		text:SetWidth(tooltip:GetWidth() - 40);
		text:Hide();
		obj.desc = text;

		text = Peggle:CreateCaption(0,0,TOOLTIP_TALENT_LEARN, tooltip, 14, 0, 1, 0, nil, true)
		text:ClearAllPoints();
		text:SetPoint("Bottom", 0, 16);
		text:SetJustifyH("LEFT");
		text:SetWidth(tooltip:GetWidth() - 40);
		text:Hide();
		obj.learn = text;

		text = Peggle:CreateCaption(0,0,const.locale["MOUSE_OVER"], tooltip, 14, 0, 1, 0, nil, true)
		text:ClearAllPoints();
		text:SetPoint("Center", 0, 0);
		text:SetWidth(tooltip:GetWidth() - 120);
		obj.mouseOver = text;

	text = Peggle:CreateCaption(0,0,"", obj, 18, 1, 0.82, 0.0, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -350);
	text:SetWidth(obj:GetWidth() - 20);
	obj.pointsLeft = text;

	obj = CreateButton(0, 0, 50, "buttonResetTalents", true, "talentReset", frame, function (self)
		
		local data = DataUnpack(playerData[DATA], SeedFromName(localPlayerName))
		if not data then
			data = RebuildPlayerData();
		else
			data = string.sub(data, 1, 7 + 12*4) .. ToBase70(100000000000, 7) .. string.sub(data, 6 + 12*4 + 8);
		end
		playerData[DATA] = DataPack(data, SeedFromName(localPlayerName));
		local i;
		for i = 1, 11 do 
			talentData[33 + i] = 0;
		end
		Talents_UpdateDisplay();
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Bottom", 0, 18);

--[[
	-- Create "Cheat" button
	obj = CreateFrame("Button", nil, obj, "OptionsButtonTemplate")
	obj:SetText("Toggle Talent Cheat");
	obj:ClearAllPoints()
	obj:SetWidth(160);
	obj:SetPoint("Top", obj:GetParent(), "Bottom", 0, -4)
	obj:SetScript("OnClick", function (self)
		PeggleData.talentCheat = (PeggleData.talentCheat ~= true)
		obj:GetParent():GetScript("OnClick")();
		Talents_UpdateDisplay();
	end);
--]]

	-- talent border
	local tree = CreateFrame("Frame", "", frame);
	tree:SetPoint("Topright", frame, "Topleft", 8, 0)
	tree:SetPoint("Bottomright", frame, "Bottomleft", 8, 0)
	tree:SetWidth(300);
	frame.tree = tree;

	tree:SetBackdrop(windowBackdrop);
	tree:SetBackdropColor(0.43,0.43,0.43,0);
	tree:SetBackdropBorderColor(1,1,1);

	local tex = tree:CreateTexture(nil, "Background");
	tex:SetTexture(const.artPath .. "bg7");
	tex:SetPoint("Topleft", 4, -4);
	tex:SetWidth(294);
	tex:SetHeight(frame:GetHeight() - 12);
	tex:SetTexCoord(0.30, 0.80, 0.2, 0.9);
	tex:SetVertexColor(0.3, 0.3, 0.3);
	tree.background = tex;

	local x1 = 26 + 40 + 25
	local x2 = 26 + 40 + 80 + 25
	local x3 = 26 + 25;
	local x4 = 26 + (80 * 1) + 25;
	local x5 = 26 + (80 * 2) + 25;
	local y = -21 - 60;

	tree.node = {};

	local OnEnter = function (self)
		local id = self:GetID();
		local frame = window.catagoryScreen.frames[4];
		local currentRank, maxRank, tier, prereq = Talents_GetTalentInfo(id);
		local freePoints, usedPoints, totalPoints = Talents_GetTalentPointInfo();
		local learn = true;
		frame.mouseOver:Hide();
		frame.name:SetText(const.locale["_TALENT" .. id .. "_NAME"]);
		frame.rank:SetFormattedText(const.locale["_RANK"], currentRank, maxRank);

		frame.icon:SetTexture(const.artPath .. const.talentTex[id]);
		frame.icon:Show();

		local talentText = "";
		if (prereq > 0) and (Talents_GetTalentInfo(prereq) == 0)  then
			talentText = talentText .. string.format(const.locale["_REQUIRES_5"], const.locale["_TALENT" .. prereq .. "_NAME"]);
			learn = nil;
		end
		if (usedPoints < tier * 5) then
			talentText = talentText .. string.format(const.locale["_REQUIRES_X"], tier * 5);
			learn = nil;
		end
		if (currentRank == maxRank) then
			learn = nil;
		end

		local nextRankText = " ";
		if (currentRank > 0) and (currentRank < maxRank) then
			nextRankText = "|cFFFFFFFF" .. TOOLTIP_TALENT_NEXT_RANK .. "|r\n" .. string.format(const.locale["_TALENT" .. id .. "_DESC"], const.factors[id * 2 - 1] + (currentRank+1) * const.factors[id * 2])
		end

		local currentRankText;
		if (currentRank == 0) then
			currentRank = 1;
		end
		currentRankText = string.format(const.locale["_TALENT" .. id .. "_DESC"], const.factors[id * 2 - 1] + currentRank * const.factors[id * 2])				


		frame.desc:SetText(talentText .. "|r" .. currentRankText .. "\n\n" .. nextRankText);

		frame.name:Show();
		frame.rank:Show();
		frame.desc:Show();
		if (freePoints > 0) and (learn) then
			frame.learn:Show();
		else
			frame.learn:Hide();
		end
	end

	local OnLeave = function (self)
		local frame = window.catagoryScreen.frames[4];
		frame.mouseOver:Show();
		frame.name:Hide();
		frame.rank:Hide();
		frame.desc:Hide()
		frame.learn:Hide();
		frame.icon:Hide();
	end

	tex = const.talentTex;

	local CreateTalent = function (x, y, id, parent, OnEnter, OnLeave, hasPath, hasArrow)
		local obj = CreateFrame("Button", "PeggleTalent" .. id, parent, "TalentButtonTemplate");
		obj:SetPoint("Topleft", x, y);
		obj:SetID(id);
		obj:GetNormalTexture():SetTexture(0,0,0,0);
		obj.rank = getglobal(obj:GetName() .. "Rank");
		obj.border = getglobal(obj:GetName() .. "Slot");
		obj.icon = getglobal(obj:GetName() .. "IconTexture");
		obj.icon:SetTexture(const.artPath .. tex[id]);
		obj:SetScript("OnClick", Talents_AssignTalent);
		obj:SetScript("OnEnter", OnEnter);
		obj:SetScript("OnLeave", OnLeave);
		if (hasPath) then
			obj.arrow = obj:CreateTexture(nil, "Background", "TalentBranchTemplate");
			obj.arrow:SetTexCoord(unpack(TALENT_BRANCH_TEXTURECOORDS.down[-1]));
			obj.arrow:SetPoint("Topleft", obj, "Bottomleft", 2, -1);
		elseif (hasArrow) then
			obj.arrow = obj:CreateTexture(nil, "Overlay", "TalentArrowTemplate");
			obj.arrow:SetTexCoord(unpack(TALENT_ARROW_TEXTURECOORDS.top[-1]));
			obj.arrow:SetPoint("Topleft", 2, 17);
		end
		return obj;
	end

	tinsert(tree.node, CreateTalent(x1, y, 1, tree, OnEnter, OnLeave));
	tinsert(tree.node, CreateTalent(x2, y, 2, tree, OnEnter, OnLeave));
	y = y - 61;
	tinsert(tree.node, CreateTalent(x3, y, 3, tree, OnEnter, OnLeave));
	tinsert(tree.node, CreateTalent(x4, y, 4, tree, OnEnter, OnLeave));
	tinsert(tree.node, CreateTalent(x5, y, 5, tree, OnEnter, OnLeave));
	y = y - 61;
	tinsert(tree.node, CreateTalent(x1, y, 6, tree, OnEnter, OnLeave));
	tinsert(tree.node, CreateTalent(x2, y, 7, tree, OnEnter, OnLeave));
	y = y - 61;
	tinsert(tree.node, CreateTalent(x1, y, 8, tree, OnEnter, OnLeave, true));
	tinsert(tree.node, CreateTalent(x2, y, 9, tree, OnEnter, OnLeave, true));
	y = y - 61;
	tinsert(tree.node, CreateTalent(x1, y, 10, tree, OnEnter, OnLeave, nil, true));
	tinsert(tree.node, CreateTalent(x2, y, 11, tree, OnEnter, OnLeave, nil, true));

	return frame;

end

local function CreateTab_HowToPlay()

	local obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 5, -9)
	obj:SetPoint("BottomRight", -4, 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.0,0.0,0.0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 1);
	tinsert(window.catagoryScreen.frames, obj);
	local frame = obj;
	obj.showID = 1;
	obj:Hide();

	obj:SetScript("OnShow", function (self)
		self.showID = 1;
		self:UpdateDisplay(self.showID);
	end);

	obj.UpdateDisplay = function (self, showID)
		local i
		for i = 1, 4 do 
			self["highlight" .. i].tex:SetAlpha(0);
			self["content" .. i]:Hide();
			if (self.showID == i) then
				self["highlight" .. i].tex:SetAlpha(1);
				self["content" .. i]:Show();
			end
		end
	end

	-- Create list

	local listBorder = CreateFrame("Frame", "", frame);
	listBorder:SetPoint("Topleft", 10, -10)
	listBorder:SetPoint("Bottomleft", 10, 10);
	listBorder:SetWidth(180);
	windowBackdrop.bgFile = const.artPath .. "windowBackground";
	windowBackdrop.tileSize = 128;
	listBorder:SetBackdrop(windowBackdrop);
	listBorder:SetBackdropColor(0,0,0,0.5);
	listBorder:SetBackdropBorderColor(1,0.8,0.45);

	local itemOnEnter = function (self)
		frame = self:GetParent():GetParent();
		if (frame.showID ~= self:GetID()) then
			self.tex:SetAlpha(0.5);
		end
	end

	local itemOnLeave = function (self)
		frame = self:GetParent():GetParent();
		if (frame.showID ~= self:GetID()) then
			self.tex:SetAlpha(0);
		end
	end

	local itemOnClick = function (self)
		local frame = self:GetParent():GetParent();
		if (frame.showID ~= self:GetID()) then
			frame.showID = self:GetID();
			frame:UpdateDisplay(self:GetID());
		end
	end

	local i, tex, seg;
	for i = 1, 4 do 

		text = Peggle:CreateCaption(10, 10 + (i - 1) * 20, const.locale["HOW_TO_PLAY" .. i], listBorder, 19, 1, 1, 1, 1, nil)
		text:SetWidth(180 - 16);
		text:SetHeight(14);
		text:SetJustifyH("LEFT") 

		obj = CreateFrame("Frame", "", listBorder);
		obj:SetWidth(180 - 16);
		obj:SetHeight(20);
		obj:SetPoint("Topleft", 10, - 6 - (i - 1) * 20);
		obj:SetScript("OnEnter", itemOnEnter);
		obj:SetScript("OnLeave", itemOnLeave);
		obj:SetScript("OnMouseUp", itemOnClick);
		obj.tex = listBorder:CreateTexture(nil, "Artwork");
		obj.tex:SetAllPoints(obj);
		obj.tex:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
		obj.tex:SetVertexColor(0.1,0.75,1);
		obj.tex:SetAlpha(0);
		obj.tex:SetBlendMode("ADD");
		obj:EnableMouse(true);
		obj:SetID(i);
		frame["highlight" .. i] = obj;
	end

	-- Create content area
	-- Content #1
	local content = CreateFrame("Frame", "", frame);
	content:SetPoint("Topleft", listBorder, "Topright");
	content:SetPoint("Bottomright", -10, 10);
	content:Hide();
	frame.content1 = content;

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY1"], content, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -22);

		local seg = const.artCut["howToPlay1"];
		local tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 520 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 520 + 0.5));
		tex:SetPoint("Topleft", 10, -70);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

		seg = const.artCut["howToPlay2"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 520 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 520 + 0.5));
		tex:SetPoint("Topright", -10, -70);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

		seg = const.artCut["howToPlay3"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 520 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 520 + 0.5));
		tex:SetPoint("Bottomleft", 10, 20);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

		seg = const.artCut["howToPlay4"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 520 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 520 + 0.5));
		tex:SetPoint("Bottomright", -10, 20);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));
--]]

	content = CreateFrame("Frame", "", frame);
	content:SetPoint("Topleft", listBorder, "Topright");
	content:SetPoint("Bottomright", -10, 10);
	content:Hide();
	frame.content2 = content;

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY2"], content, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -22);

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY2a"], content, 11, 1, 1, 1, nil, nil)
		text:SetWidth(content:GetWidth() - 20);
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -64);

		seg = const.artCut["howToPlay5"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 500 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 500 + 0.5));
		tex:SetPoint("Top", text, "Bottom", 0, -10);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY2b"], content, 11, 1, 1, 1, nil, nil)
		text:SetWidth(content:GetWidth() - 20);
		text:ClearAllPoints();
		text:SetPoint("Top", tex, "Bottom", 0, -10);

		seg = const.artCut["howToPlay6"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 500 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 500 + 0.5));
		tex:SetPoint("Top", text, "Bottom", 0, -10);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

	content = CreateFrame("Frame", "", frame);
	content:SetPoint("Topleft", listBorder, "Topright");
	content:SetPoint("Bottomright", -10, 10);
	content:Hide();
	frame.content3 = content;

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY3"], content, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -22);

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY3a"], content, 11, 1, 1, 1, nil, nil)
		text:SetWidth(content:GetWidth() - 20);
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -64);

		seg = const.artCut["howToPlay7"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 500 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 500 + 0.5));
		tex:SetPoint("Top", text, "Bottom", 0, -10);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY3b"], content, 11, 1, 1, 1, nil, nil)
		text:SetWidth(content:GetWidth() - 20);
		text:ClearAllPoints();
		text:SetPoint("Top", tex, "Bottom", 0, -10);

	content = CreateFrame("Frame", "", frame);
	content:SetPoint("Topleft", listBorder, "Topright");
	content:SetPoint("Bottomright", -10, 10);
	content:Hide();
	frame.content4 = content;

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY4"], content, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -22);

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY4a"], content, 11, 1, 1, 1, nil, nil)
		text:SetWidth(content:GetWidth() - 20);
		text:ClearAllPoints();
		text:SetPoint("Top", content, "Top", 0, -64);

		seg = const.artCut["howToPlay8"];
		tex = content:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[2] - seg[1]) * 500 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 500 + 0.5));
		tex:SetPoint("Top", text, "Bottom", 0, -10);
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetTexCoord(unpack(seg));

		text = Peggle:CreateCaption(0, 0, const.locale["HOW_TO_PLAY4b"], content, 11, 1, 1, 1, nil, nil)
		text:SetWidth(content:GetWidth() - 20);
		text:ClearAllPoints();
		text:SetPoint("Top", tex, "Bottom", 0, -10);

	return frame;
--[[
	["HOW_TO_PLAY1"] = "Basic Gameplay",
	["HOW_TO_PLAY2"] = "Duel Mode",
	["HOW_TO_PLAY2a"] = "Duel Mode allows you to challenge another player to a 1-on-1, ten shot, " .. 
	["HOW_TO_PLAY2b"] = "After participating in a duel, the summary screen shows how you fared vs " ..
	["HOW_TO_PLAY3"] = "Challenge Mode",
	["HOW_TO_PLAY3a"] = "Challenge Mode lets you set up special challenges between many of your " ..
	["HOW_TO_PLAY3b"] = "Challenges that have run out of time will eventually decay off your list.",
	["HOW_TO_PLAY4"] = "Peggle Loot",
	["HOW_TO_PLAY4a"] = "Peggle Loot is a fun way to distribute loot in a Master Looter party or raid. " ..
	["HOW_TO_PLAY4b"] = "The addon will pick a random level, and then send that challenge to all members " ..
--]]

end

local function CreateTab_Options()

	local obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 5, -9)
	obj:SetPoint("BottomRight", -4, 4);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.0,0.0,0.0,0.5);
	obj:SetBackdropBorderColor(1,1,1);
	obj:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 1);
	tinsert(window.catagoryScreen.frames, obj);
	local frame = obj;
	obj:Hide();

--[[
	["OPT_TRANS_DEFAULT"] = "Mouse-on Transparency",
	["OPT_TRANS_MOUSE"] = "Mouse-off Transparency",
	["OPT_MINIMAP"] = "Show Mini-map Icon",
	["OPT_NEW_ON_FLIGHT"] = "New Game on Flight Start",
	["OPT_SOUNDS"] = "Sounds:",
	["OPT_SOUNDS_NORMAL"] = "Normal",
	["OPT_SOUNDS_QUIET"] = "Quiet",
	["OPT_SOUNDS_OFF"] = "Off",
	["OPT_LOCK"] = "Lock Window",
	["OPT_AUTO_OPEN"] = "Auto-Open:",
	["OPT_AUTO_OPEN1"] = "On Flight Start",
	["OPT_AUTO_OPEN2"] = "On Death",
	["OPT_AUTO_OPEN3"] = "On Log-in",
	["OPT_AUTO_OPEN4"] = "Duel Invite",
	["OPT_AUTO_CLOSE"] = "Auto-Close:",
	["OPT_AUTO_CLOSE1"] = "On Flight End",
	["OPT_AUTO_CLOSE2"] = "On Ready Check",
	["OPT_AUTO_CLOSE3"] = "On Enter Combat",
	["OPT_AUTO_CLOSE4"] = "Duel Complete",
	["OPT_DUEL_INVITES"] = "Duel/Challenge Invites:"
	["OPT_DUEL_INVITES1"] = "Chatbox Text Alert"
	["OPT_DUEL_INVITES2"] = "Raid Warning Text Alert"
	["OPT_DUEL_INVITES3"] = "Mini-map Icon Alert"
	["OPT_DUEL_INVITES4"] = "Auto-decline Duels"

	mouseOnTrans = 1,
	mouseOffTrans = 0.6,
	showMinimapIcon = true,
	openFlightStart = true,
	openDeath = true,
	openLogIn = false,
	openDuel = true,
	closeFlightEnd = false,
	closeReadyCheck = true,
	closeCombat = true,
	closeDuelComplete = true,
	inviteChat = true,
	inviteRaid = false,
	inviteMinimap = true,
	inviteDecline = true,

--]]

	local xLoc = 230;
	local yLoc = 100;

	obj = Peggle:CreateSlider(xLoc, yLoc, 300, const.locale["OPT_TRANS_DEFAULT"], "mouseOnTrans", frame, 0.1, 1, 0.01, true, function (self)
		window:SetAlpha(PeggleData.settings.mouseOnTrans);
	end);
	obj:ClearAllPoints();
	obj:SetPoint("Top", 0, -30);
	obj = Peggle:CreateSlider(xLoc, yLoc, 300, const.locale["OPT_TRANS_MOUSE"], "mouseOffTrans", frame, 0.0, 1, 0.01, true, nil)
	obj:ClearAllPoints();
	obj:SetPoint("Top", 0, -70);

	obj = CreateCheckbox(xLoc, yLoc, const.locale["OPT_MINIMAP"], "showMinimapIcon", true, frame, function (self)
		PeggleData.settings[self.key] = (self:GetChecked() == 1);
		if (self:GetChecked() == 1) then
			window.minimap:Show();
		else
			window.minimap:Hide();
		end
	end, 1, 0.82, 0); 

	local updateFunc = function (self)
		PeggleData.settings[self.key] = (self:GetChecked() == 1);
	end;

	obj = CreateCheckbox(xLoc, yLoc+20, const.locale["OPT_COLORBLIND"], "colorBlindMode", true, frame, updateFunc, 1, 0.82, 0); 
	obj = CreateCheckbox(xLoc, yLoc+40, const.locale["OPT_HIDEOUTDATED"], "hideOutdated", true, frame, updateFunc, 1, 0.82, 0); 

--	obj = CreateDropdown(xLoc, yLoc+52, 150, "defaultPublish", const.locale["OPT_PUBLISH"], nil, frame, nil)
--	obj.publish = true;
	xLoc = 50;
	yLoc = 150 + 60 - 8 - 20;
		
	obj = Peggle:CreateCaption(xLoc, yLoc, const.locale["OPT_AUTO_OPEN"], frame, 14, 1, 1, 0)
	obj = CreateCheckbox(xLoc, yLoc+20, const.locale["OPT_AUTO_OPEN1"], "openFlightStart", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+40, const.locale["OPT_AUTO_OPEN2"], "openDeath", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+60, const.locale["OPT_AUTO_OPEN3"], "openLogIn", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+80, const.locale["OPT_AUTO_OPEN4"], "openDuel", true, frame, updateFunc, 1, 0.82, 0);

	xLoc = 270;
	obj = Peggle:CreateCaption(xLoc, yLoc, const.locale["OPT_AUTO_CLOSE"], frame, 14, 1, 1, 0)
	obj = CreateCheckbox(xLoc, yLoc+20, const.locale["OPT_AUTO_CLOSE1"], "closeFlightEnd", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+40, const.locale["OPT_AUTO_CLOSE2"], "closeReadyCheck", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+60, const.locale["OPT_AUTO_CLOSE3"], "closeCombat", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+80, const.locale["OPT_AUTO_CLOSE4"], "closeDuelComplete", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+100, const.locale["OPT_AUTO_CLOSE5"], "closePeggleLoot", true, frame, updateFunc, 1, 0.82, 0);

	local soundUpdateFunc = function (self)
		local prev = PeggleData.settings.soundVolume;
		PeggleData.settings.soundVolume = self:GetID();
		getglobal("PeggleCheckbox_soundVolume1"):SetChecked(false);
		getglobal("PeggleCheckbox_soundVolume2"):SetChecked(false);
		getglobal("PeggleCheckbox_soundVolume3"):SetChecked(false);
		self:SetChecked(true);

		self.updating = true;
		local button = getglobal("PeggleButton_soundButton");
		if not button.updating then
			if (button.off == 1) and (self:GetID() ~= 2) then
				button.hover = true;
				button.prev = self:GetID();
				button:GetScript("OnClick")(button);
				button.hover = nil;
			elseif ((button.off == 0) or (button.off == nil)) and (self:GetID() == 2)  then
				button.hover = true;
				button.prev = prev;
				button:GetScript("OnClick")(button);
				button.hover = nil;
			end
		end
		self.updating = nil;
	end
	xLoc = 490;
	obj = Peggle:CreateCaption(xLoc, yLoc, const.locale["OPT_SOUNDS"], frame, 14, 1, 1, 0)
	obj = CreateCheckbox(xLoc, yLoc+20, const.locale["OPT_SOUNDS_NORMAL"], "soundVolume1", true, frame, soundUpdateFunc, 1, 0.82, 0);
	obj:SetID(0);
	if (PeggleData.settings.soundVolume == 0) then
		obj:SetChecked(true);
	end
	obj = CreateCheckbox(xLoc, yLoc+40, const.locale["OPT_SOUNDS_QUIET"], "soundVolume2", true, frame, soundUpdateFunc, 1, 0.82, 0);
	obj:SetID(1);
	if (PeggleData.settings.soundVolume == 1) then
		obj:SetChecked(true);
	end
	obj = CreateCheckbox(xLoc, yLoc+60, const.locale["OPT_SOUNDS_OFF"], "soundVolume3", true, frame, soundUpdateFunc, 1, 0.82, 0);
	obj:SetID(2);
	if (PeggleData.settings.soundVolume == 2) then
		obj:SetChecked(true);
	end

	if (PeggleData.settings.soundVolume == 2) then
		local button = getglobal("PeggleButton_soundButton");
		button.hover = true;
		button:GetScript("OnClick")(button);
	end


	xLoc = 50;
	yLoc = yLoc + 120 + 20
	obj = Peggle:CreateCaption(xLoc, yLoc, const.locale["OPT_DUEL_INVITES"], frame, 14, 1, 1, 0)
	obj = CreateCheckbox(xLoc, yLoc+20, const.locale["OPT_DUEL_INVITES1"], "inviteChat", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+40, const.locale["OPT_DUEL_INVITES2"], "inviteRaid", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+60, const.locale["OPT_DUEL_INVITES3"], "inviteMinimap", true, frame, updateFunc, 1, 0.82, 0);
	obj = CreateCheckbox(xLoc, yLoc+80, const.locale["OPT_DUEL_INVITES4"], "inviteDecline", true, frame, updateFunc, 1, 0.82, 0);

	obj = CreateButton(360, yLoc + 10, 44, "buttonAbout", true, "about", frame, function (self)
		window.catagoryScreen.frames[6]:Hide();
		window.about:Show();
	end, nil, true);
	obj = CreateButton(360, yLoc + 60, 44, "buttonCredits", true, "credits", frame, function (self)
		window.catagoryScreen.frames[6]:Hide();
		window.credits:Show();
	end, nil, true);

	-- About screen
	local screen = CreateFrame("Frame", "", window.catagoryScreen);
	screen:SetPoint("TopLeft", 5, -9)
	screen:SetPoint("BottomRight", -4, 4);

--	local windowBackdrop = const.GetBackdrop();
--	windowBackdrop.tileSize = 128;
--	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
--	windowBackdrop.edgeSize = 32;

	screen:SetBackdrop(windowBackdrop);
	screen:SetBackdropColor(0.0,0.0,0.0,0.5);
	screen:SetBackdropBorderColor(1,1,1);
	screen:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 2);
	screen:Hide();
	window.about = screen;

		local text = Peggle:CreateCaption(0, 0, const.locale["ABOUT"], screen, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", 0, -20);

		local seg = const.artCut["popCap"];
		local tex = screen:CreateTexture(nil, "Artwork");
		tex:SetTexture(const.artPath .. "board1");
		tex:SetTexCoord(unpack(seg));
		tex:SetWidth(floor((seg[2] - seg[1]) * 512 * 1.5 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 512 * 1.5 + 0.5));
		tex:ClearAllPoints();
		tex:SetPoint("Bottom", 0, 114);

		text = Peggle:CreateCaption(0, 0, const.locale["ABOUT_TEXT1"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", 0, -60);
		text:SetWidth(screen:GetWidth() - 60);

		text = Peggle:CreateCaption(0, 0, const.locale["ABOUT_TEXT4"] .. const.versionString, screen, 14, 1, 1, 1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Topright", -20, -20);

		text = Peggle:CreateCaption(0, 0, const.locale["ABOUT_TEXT3"], screen, 9, 1, 1, 0, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Bottom", 0, 10);
		text:SetWidth(screen:GetWidth() - 60);

		text = Peggle:CreateCaption(0, 0, const.locale["ABOUT_TEXT2"], screen, 15, 1, 0.85, 0.1, nil, nil)
		text:ClearAllPoints();
		text:SetPoint("Bottom", 0, 80);
		text:SetWidth(screen:GetWidth() - 60);

		obj = CreateButton(0, 0, 40, "buttonOkay", nil, "aboutOkay", screen, function (self)
			window.catagoryScreen.frames[6]:Show();
			self:GetParent():Hide();
		end)
		obj:ClearAllPoints();
		obj:SetPoint("Bottom", 0, 30);

	-- Credits screen
	screen = CreateFrame("Frame", "", window.catagoryScreen);
	screen:SetPoint("TopLeft", 5, -9)
	screen:SetPoint("BottomRight", -4, 4);

--	windowBackdrop = const.GetBackdrop();
--	windowBackdrop.tileSize = 128;
--	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
--	windowBackdrop.edgeSize = 32;

	screen:SetBackdrop(windowBackdrop);
	screen:SetBackdropColor(0.0,0.0,0.0,0.5);
	screen:SetBackdropBorderColor(1,1,1);
	screen:SetFrameLevel(window.catagoryScreen:GetFrameLevel() + 2);
	screen:Hide();
	window.credits = screen;

		text = Peggle:CreateCaption(0, 0, const.locale["CREDITS"], screen, 40, 0.05, 0.66, 1, 1, nil)
		text:ClearAllPoints();
		text:SetPoint("Top", 0, -20);

		seg = const.artCut["peggleBringer"];
		tex = screen:CreateTexture(nil, "Artwork")
		tex:SetPoint("Top", -(screen:GetWidth() / 4) - 20, -10);
		tex:SetWidth(floor((seg[4] - seg[3]) * (512-128) + 0.5));
		tex:SetHeight(floor((seg[2] - seg[1]) * (512-128) + 0.5));
		tex:SetTexture(const.artPath .. "board1");
		tex:SetTexCoord(seg[2], seg[3], seg[1], seg[3], seg[2], seg[4], seg[1], seg[4]);

		tex = screen:CreateTexture(nil, "Artwork")
		tex:SetPoint("Top", (screen:GetWidth() / 4) + 20, -10);
		tex:SetWidth(floor((seg[4] - seg[3]) * (512-128) + 0.5));
		tex:SetHeight(floor((seg[2] - seg[1]) * (512-128) + 0.5));
		tex:SetTexture(const.artPath .. "board1");
		tex:SetTexCoord(seg[2], seg[4], seg[1], seg[4], seg[2], seg[3], seg[1], seg[3]);

--[[


		seg = const.artCut["popCap"];
		tex = screen:CreateTexture(nil, "Artwork");
		tex:SetTexture(const.artPath .. "board1");
		tex:SetTexCoord(unpack(seg));
		tex:SetWidth(floor((seg[2] - seg[1]) * 512 * 1.5 + 0.5));
		tex:SetHeight(floor((seg[4] - seg[3]) * 512 * 1.5 + 0.5));
		tex:ClearAllPoints();
		tex:SetPoint("Bottom", 0, 114);
--]]
		local yLoc = 60;
		local xLoc = 20;
		text = Peggle:CreateCaption(xLoc, yLoc, const.locale["CREDITS1"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 20, yLoc + 20, const.locale["CREDITS1a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
		yLoc = yLoc + 25 + 15 * 1

		text = Peggle:CreateCaption(xLoc, yLoc, const.locale["CREDITS2"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 20, yLoc + 20, const.locale["CREDITS2a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
		yLoc = yLoc + 25 + 15 * 1

		text = Peggle:CreateCaption(xLoc, yLoc, const.locale["CREDITS3"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 20, yLoc + 20, const.locale["CREDITS3a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
		yLoc = yLoc + 25 + 15 * 2

		text = Peggle:CreateCaption(xLoc, yLoc, const.locale["CREDITS4"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 20, yLoc + 20, const.locale["CREDITS4a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
		yLoc = yLoc + 25 + 15 * 1

		text = Peggle:CreateCaption(xLoc, yLoc, const.locale["CREDITS5"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 20, yLoc + 20, const.locale["CREDITS5a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
		yLoc = yLoc + 25 + 15 * 2

		text = Peggle:CreateCaption(xLoc, yLoc, const.locale["CREDITS6"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 20, yLoc + 20, const.locale["CREDITS6a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");

		local xLoc = screen:GetWidth() / 2;
		yLoc = 60;
		text = Peggle:CreateCaption(xLoc + 10, yLoc, const.locale["CREDITS7"], screen, 16, 1, 1, 0, nil, nil)
		text = Peggle:CreateCaption(xLoc + 30, yLoc + 20, const.locale["CREDITS7a"], screen, 14, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");

		yLoc = yLoc + 25 + 15 * 6 + 20

		text = Peggle:CreateCaption(xLoc + 10, yLoc, const.locale["CREDITS8"], screen, 16, 1, 1, 0, nil, nil)

		xLoc = screen:GetWidth() / 3;

		text = Peggle:CreateCaption(xLoc, yLoc + 16, const.locale["CREDITS8a"], screen, 12, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
		text = Peggle:CreateCaption(xLoc + 200, yLoc + 16, const.locale["CREDITS8b"], screen, 12, 1, 0.85, 0.1, nil, nil)
		text:SetJustifyH("LEFT");
--		yLoc = yLoc + 25 + 15 * 1

		obj = CreateButton(0, 0, 40, "buttonOkay", nil, "aboutOkay", screen, function (self)
			window.catagoryScreen.frames[6]:Show();
			self:GetParent():Hide();
		end)
		obj:ClearAllPoints();
		obj:SetPoint("Bottom", 0, 14);



	return frame;

end

local function CreateTabCatagoryDialog()

	local obj = CreateFrame("Frame", "", window);
	obj:SetPoint("TopLeft", 8, -80)
	obj:SetWidth(window:GetWidth() - 16 - 2);
	obj:SetHeight(window:GetHeight() - 80 - 6 - 2);
--	obj:SetPoint("BottomRight", -8, 8);

--	obj = CreateFrame("Frame", "", obj);
--	obj:SetPoint("TopLeft")
--	obj:SetWidth(window:GetWidth() - 16 - 2);
--	obj:SetHeight(window:GetHeight() - 80 - 6 - 2);
--	obj:SetPoint("BottomRight", -8, 8);

	local frame = CreateFrame("Frame", "", obj);
	frame:SetFrameLevel(frame:GetFrameLevel() + 4);
	frame:SetWidth(20);
	frame:SetHeight(20);
	frame:SetPoint("Bottom");
	const.outdatedText = Peggle:CreateCaption(0, 0, const.locale["OUT_OF_DATE"], frame, 11, 1, 1, 1, nil, nil)
	const.outdatedText:ClearAllPoints();
	const.outdatedText:SetPoint("Bottom", 0, 0);
	const.outdatedText:Hide();
	const.outdatedText:SetAlpha(1);

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.bgFile = const.artPath .. "windowBackground";
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.43,0.43,0.43,1);
	obj:SetBackdropBorderColor(1,0.8,0.45);
	obj:SetFrameLevel(window:GetFrameLevel() + 1);

	window.catagoryScreen = obj;
	obj.frames = {};
	obj:Hide();

	obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetWidth(653)
	obj:SetHeight(64);
	obj:SetPoint("Topleft", -4, 54);
	obj:SetFrameLevel(window:GetFrameLevel() + 2);
	window.catagoryScreen.tabFrame = obj;

	local currentX = 0;
	local tab;
	tab, currentX = CreateTab(currentX, 0, obj, CreateTab_QuickPlay(), "tabQuickPlay", nil);
	tab.focus = true;
	tab.contentFrame:Show();
	window.catagoryScreen.lastFocus = tab;
	Tab_OnLeave(tab);
	tab, currentX = CreateTab(currentX, 0, obj, CreateTab_Duel(), "tabDuel", nil, 3);
	window.duelTab = tab;
	tab, currentX = CreateTab(currentX, 0, obj, CreateTab_Challenge(), "tabChallenge", nil, 3);
	window.challengeTabSparks = tab.sparks;
	tab, currentX = CreateTab(currentX, 0, obj, CreateTab_Talents(), "tabTalents", nil, 3);
	window.sparks = tab.sparks;
--	tab.sparks:Show();
	tab, currentX = CreateTab(currentX, 0, obj, CreateTab_HowToPlay(), "tabHowToPlay", true);
	window.catagoryScreen.tabFrame.currentX = currentX;
--	tab, currentX = CreateTab(currentX, 0, obj, CreateTab_Options(), "tabOptions", nil);
	
	-- Splash Screen Creation

	obj = CreateFrame("Frame", "", window.catagoryScreen);
	obj:SetPoint("TopLeft", 5, -9)
	obj:SetPoint("BottomRight", -4, 4);
	obj:SetFrameLevel(obj:GetFrameLevel() + 10);
	obj:EnableMouse(true);
	obj:Hide();
	obj:SetScript("OnShow", function (self)
		local i;
		for i = 1, 6 do 
			window.catagoryScreen.frames[i]:SetAlpha(0);
		end
		const.outdatedText:SetAlpha(0);
	end);
	obj:SetScript("OnHide", function (self)
		local i;
		for i = 1, 6 do 
			window.catagoryScreen.frames[i]:SetAlpha(1);
		end
		const.outdatedText:SetAlpha(1);
	end);
	obj:SetScript("OnUpdate", function (self, elapsed)
		-- Don't do anything while the legal screen is up
		if not self.elapsed then
			return;
		end
		if not const.name then
			const.name = UnitName("player");
		end
		self.elapsed = self.elapsed + min(elapsed, 0.2);
		if (self.elapsed >= 4) then
			self:Hide();
			self.elapsed = nil;
			self.showScreen = nil;
			self.background = nil;
			self.foreground = nil;
			self.legal = nil;
			window.splash = nil;
			return;
		end
		if (self.elapsed > 3) then
			if not self.showScreen then
				self.showScreen = true
				local i;
				for i = 1, 6 do 
					window.catagoryScreen.frames[i]:SetAlpha(1);
				end
			end
			self:SetAlpha(max(1 - (self.elapsed - 3), 0));
		end
	end);
	window.splash = obj;

	local text = Peggle:CreateCaption(0, 0, const.locale["LEGAL1"], obj, 12, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Bottom", obj, "Bottom", 0, 20);

	local tex = obj:CreateTexture(nil, "Artwork");
	tex:SetWidth(640)
	tex:SetHeight(640);
	tex:SetPoint("Center", 1, 0);
	tex:SetTexture(const.artPath .. "splashBackground");
--	tex:SetAlpha(0);
	obj.background = tex;

	local seg = const.artCut["splashBringer"];
	tex = obj:CreateTexture(nil, "Overlay");
	tex:SetWidth(floor((seg[2] - seg[1]) * 520 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 520 + 0.5));
	tex:SetPoint("Center");
	tex:SetTexture(const.artPath .. "banner2");
	tex:SetTexCoord(unpack(seg));
--	tex:SetAlpha(0);
	obj.foreground = tex;

end

local function Event_VariablesLoaded(self, event, ...)

	Event_VariablesLoaded = nil;

	if (PeggleData.version and (PeggleData.version < 1.00)) then
		PeggleData.version = nil;
	end

	if not PeggleData.version then
		PeggleData = {};
		PeggleData.data = "i4g`Z@ah38hdf8j387r6hfedh7FHJKEFH3y89hfjiofdHUUEBUnudy73P7Vmr=h7ZuSBG";
		PeggleData.settings = {
			mouseOnTrans = 1,
			mouseOffTrans = 0.6,
			showMinimapIcon = true,
			openFlightStart = true,
			openDeath = true,
			openLogIn = true,
			openDuel = true,
			closeFlightEnd = false,
			closeReadyCheck = true,
			closeCombat = true,
			closeDuelComplete = false,
			closePeggleLoot = false,
			inviteChat = true,
			inviteRaid = false,
			inviteMinimap = true,
			inviteDecline = false,
			hideOutdated = false;
			soundVolume = 0,
			minimapAngle = 270,
			defaultPublish = "GUILD",
		};
		PeggleData.version = const.versionID;
		PeggleData.recent = {};
		PeggleProfile = {};
		PeggleProfile.challenges = {};
		PeggleProfile.lastDuels = {};
		PeggleProfile.duelTracking = {};
		PeggleProfile.levelTracking = {};
		PeggleProfile.version = const.versionID;
	end
--[[
	if (PeggleData.version < 0.31) then
		PeggleData.version = 0.31;
		PeggleData.challenges = nil;
		PeggleProfile = {};
		PeggleProfile.challenges = {};
		PeggleProfile.version = 0.31;
	end

	if (PeggleData.version < 0.4) then
		PeggleData.version = 0.4;
		PeggleData.challenges = nil;
		PeggleData.recent = {};
	end

	PeggleProfile = PeggleProfile or {};
	PeggleProfile.version = PeggleProfile.version or 0.3;

	-- Major per-character update
	if (PeggleProfile.version < 0.4) then
		PeggleProfile.version = 0.4;
		PeggleProfile.challenges = {};
	end

	if (PeggleProfile.version < 0.41) then
		PeggleProfile.version = 0.41;
		PeggleProfile.lastDuels = {};
		PeggleProfile.duelTracking = {};
		PeggleProfile.levelTracking = {};
	end

	if (PeggleProfile.version < 0.93) then
		PeggleProfile.version = 0.93;
		PeggleData.settings.defaultPublish = 1;
	end

	-- Minor per-character update
	if (PeggleProfile.version < const.versionID) then
		PeggleProfile.challenges = {};
		PeggleProfile.version = const.versionID;
	end

	if not PeggleProfile then
		PeggleProfile = {};
		PeggleProfile.challenges = {};
		PeggleProfile.version = const.versionID;
	end
--]]
	if not PeggleProfile.challenges then
		PeggleProfile.challenges = {};
	end

	if not localPlayerName then
		localPlayerName = UnitName("player");
		const.name = localPlayerName;
	end

	if not PeggleData.loggedIn then
		PeggleData.loggedIn = localPlayerName;
	else
		localPlayerName = PeggleData.loggedIn;
	end

	-- Per-Account update
	if (PeggleData.version < 1.02) then
		PeggleData.version = 1.02;
		PeggleData.settings.defaultPublish = const.channels[PeggleData.settings.defaultPublish];
		PeggleData.settings.hideOutdated = false;
	end

	-- Per-Character update
	if (PeggleProfile.version < 1.02) then
		PeggleProfile.challenges = {};
		PeggleProfile.version = 1.02;
	end

	playerData = PeggleData
	playerChallenges = PeggleProfile.challenges;

	localPlayerName = PeggleData.loggedIn;
	CreateTab(window.catagoryScreen.tabFrame.currentX, 0, window.catagoryScreen.tabFrame, CreateTab_Options(), "tabOptions", nil);

	-- By running this, we are checking our player data for
	-- incorrect data
	
	local data = DataUnpack(playerData[DATA], SeedFromName(localPlayerName))
	if not data then
		data = RebuildPlayerData()
	end

	-- Populate the talent tables

	Talents_GetUsedTalentPoints();

	-- Build our score data, for display only (we never save to
	-- the scoreData table, that's not its purpose)
	local recent = playerData.recent;
	local levelScores = sub(data, 8);
	local levelFlags = tostring(FromBase70(sub(data, 1, 7)));
	local i, flag;
	for i = 1, 12 do
		flag = byte(levelFlags, i+1) - 48;
		if (flag == 0) then
			scoreData[i] = 0;
		else
			scoreData[i] = FromBase70(sub(levelScores, (i - 1) * 4 + 1, i * 4));
			if not recent[i] then
				recent[i] = scoreData[i];
			end
		end
		scoreData[i + 12] = flag
	end

	local frame = window.catagoryScreen.frames[1];
	frame:UpdateDisplay(1); --.info.forced = true;
	window.levelList:UpdateList();
--	Dropdown_Item_OnClick(frame.info);

	if (PeggleData.settings.showMinimapIcon ~= true) then
		window.minimap:Hide();
	end

	if (PeggleData.settings.minimapDetached == nil) then
		window.minimap:SetPoint("Center", Minimap, "Center", - (76 * cos(rad(PeggleData.settings.minimapAngle or 270))), (76 * sin(rad(PeggleData.settings.minimapAngle or 270))))
	else
		window.minimap:SetPoint("Center", UIParent, "bottomleft", PeggleData.settings.minimapX, PeggleData.settings.minimapY);
	end

	ShowGameUI(false);

	if (PeggleData.settings.openLogIn ~= true) then
		self:Hide();
	end

	if UnitOnTaxi("player") then
		if (PeggleData.settings.openFlightStart == true) then
			self:Show();
		end
	end

	self:SetScript("OnEvent", function (self, event, arg1, arg2, arg3)
		if (event == "PLAYER_DEAD") then
			if (PeggleData.settings.openOnDeath == true) then
				self:Show();
			end
		elseif (event == "READY_CHECK") then
			if (PeggleData.settings.closeReadyCheck == true) then
				self:Hide();
			end
		elseif (event == "PLAYER_REGEN_DISABLED") then
			if (PeggleData.settings.closeCombat == true) then
				self:Hide();
			end
		elseif (event == "PLAYER_CONTROL_GAINED") then
			if (window.flying == true) then
				if (PeggleData.settings.closeFlightEnd == true) then
					window:Hide();
				end
			end
			window.flying = nil;
-- Part #3 of 4 for "Player not online" message fix
		elseif (event == "CHAT_MSG_WHSIPER_INFORM") then
			local checkName = string.lower(arg2);
			if (checkName == const.last) then
				const.last = nil;
			end
-- End fix
		end

			
--[[ -- Peggle duels
	openDuel = true,
	closeDuelComplete = true,
--]]
	end);

	self:UnregisterAllEvents();
	self:RegisterEvent("PLAYER_DEAD");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("PLAYER_CONTROL_GAINED");

-- Part #4 of 4 for "Player not online" message fix
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM");
-- End fix

-- Part #1 of 4 for "Player not online" message fix
	hooksecurefunc("SendChatMessage", function (message, chatType, language, dest)
		if (chatType == "WHISPER") then
			const.last = string.lower(dest);
		end
	end);
-- End fix

	hooksecurefunc("TakeTaxiNode", function ()
		window.flying = true;
		if (PeggleData.settings.openFlightStart == true) then
			window:Show();
		end
	end);

	window.challengeTimer:Show();
	if (playerChallenges[1]) then
		Net_OnLogIn();
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Net_ChatFilter)

	-- Legal display
	if not PeggleData.legalDisplayed then
		local obj = CreateFrame("Frame", "", window);
		obj:SetWidth(160 * 2);
		obj:SetHeight(216 + 32);
		obj:SetToplevel(true);
		obj:SetFrameStrata("High")
		obj:SetPoint("Center");
		obj:EnableMouse(true);
		window.legal = obj;

		local windowBackdrop = const.GetBackdrop();
		windowBackdrop.edgeFile = const.artPath	 .. "windowBorder"; 
		windowBackdrop.bgFile = const.artPath .. "windowBackground";
		windowBackdrop.edgeSize = 32;
		windowBackdrop.tileSize = 64;
		windowBackdrop.insets.right = 3;

		obj:SetBackdrop(windowBackdrop);
		obj:SetBackdropColor(0.43,0.43,0.43,1);
		obj:SetBackdropBorderColor(1,0.8,0.45);
		obj:SetBackdropBorderColor(1,1,1);

		local text = Peggle:CreateCaption(0, 0, "Peggle", obj, 25, 1, 0.4, 0, true, nil, "")
		text:ClearAllPoints();
		text:SetShadowColor(0,0,0);
		text:SetShadowOffset(1,-1);
		text:SetPoint("Top", 0, -38);
		text:SetWidth(160 * 1.8);
		text:Show();

		text = obj:CreateFontString(nil, "Overlay");
		text:SetFont(STANDARD_TEXT_FONT, 12);
		text:SetShadowColor(0,0,0);
		text:SetShadowOffset(1,-1);
		text:SetTextColor(1, 1, 1);
		text:SetPoint("Top", 0, -78);
		text:SetWidth(160 * 1.8);
		text:SetText(const.locale["LEGAL2"])
		text:Show();
		obj.text = text;

		local button = CreateButton(0, 0, 40, "buttonOkay", nil, "legalOkay", obj, function (self)
			window.legal:Hide();
			window.legal.text:SetText("");
			window.legal.text = nil;
			window.legal = nil;
			window.splash.elapsed = 0;
			PeggleData.legalDisplayed = true;
		end)
		button:ClearAllPoints();
		button:SetPoint("Top", text, "Bottom", 0, -16);

		obj:SetHeight(text:GetHeight() + button:GetHeight() + 120);
	end

	local obj = CreateFrame("Frame", "", window);
	obj:SetWidth(290);
	obj:SetHeight(90 + 32);
	obj:SetToplevel(true);
	obj:SetFrameStrata("High")
	obj:SetPoint("Center");
	obj:EnableMouse(true);
	const.outdatedPop = obj;
	obj:Hide();

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.edgeFile = const.artPath	 .. "windowBorder"; 
	windowBackdrop.bgFile = const.artPath .. "windowBackground";
	windowBackdrop.edgeSize = 32;
	windowBackdrop.tileSize = 64;
	windowBackdrop.insets.right = 3;

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.43,0.43,0.43,1);
	obj:SetBackdropBorderColor(1,0.8,0.45);
	obj:SetBackdropBorderColor(1,1,1);

	text = obj:CreateFontString(nil, "Overlay");
	text:SetFont(STANDARD_TEXT_FONT, 12);
	text:SetShadowColor(0,0,0);
	text:SetShadowOffset(1,-1);
	text:SetTextColor(1, 1, 1);
	text:SetPoint("Top", 0, -32);
	text:SetWidth(270);
	text:SetText(const.locale["OUT_OF_DATE"])
	text:Show();

	local button = CreateButton(0, 0, 40, "buttonOkay", nil, "outOfDateOkay", obj, function (self)
		const.outdatedPop:Hide();
	end)
	button:ClearAllPoints();
	button:SetPoint("Top", text, "Bottom", 0, -12);
	obj:SetHeight(text:GetHeight() + button:GetHeight() + 64);

	if (PeggleData.outdated) and (PeggleData.outdated <= const.ping) then
		PeggleData.outdated = nil;
	elseif (PeggleData.outdated) then
		const.outdatedText:Show();
	end

-- /script SendAddonMessage("PEGGLE", "ping+2", "WHISPER", "Moongaze")
	local seed = SeedFromName(const.addonName);
	local badFile;
	for key = 1, 12 do 
		levelString[key] = DataUnpack(levelString[key], seed);
		if not levelString[key] then
			badFile = true;
		end
	end
	local issueFound = badFile;

	-- Splash display
	window.splash:Show();
	if not window.legal then
		window.splash.elapsed = 0;
		window.splash.background:SetAlpha(1);
		window.splash.foreground:SetAlpha(1);
	end

--	if not PeggleData.exhibitA then

		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end

		-- Create our fake achievement frame

		local obj = CreateFrame("Button", "exhibitA", UIParent, "AchievementAlertFrameTemplate");
		obj:Hide();
		obj:ClearAllPoints();
		obj:SetPoint("BOTTOM", 0, 128);
		obj:SetWidth(526);
		obj:SetHeight(160);
		obj.glow:SetWidth(680);
		obj.glow:SetHeight(270);
		obj:EnableMouse(false)
		obj.shine:SetTexCoord(0,0.001,0,0.001); --SetWidth(400);
		obj.holdDuration = 5;
		window.achieve = obj;

		-- Register it to trigger at the end of a REAL duel, and
		-- if we're in a Peggle duel, it procs

		obj:RegisterEvent("DUEL_FINISHED");
		obj:SetScript("OnEvent", function (self)
			if (window.duelStatus == 3) and not PeggleData.exhibitA then
				PeggleData.exhibitA = true;

				if ( not AchievementFrame ) then
					AchievementFrame_LoadUI();
				end
				self.elapsed = 0;
				self.state = nil;
				self:SetAlpha(0);
				self.id = 0;
				self:SetScript("OnUpdate", AchievementAlertFrame_OnUpdate);
				self:UnregisterAllEvents();
				self:Show();
			end
		end);

		-- Set up achievement text image (lol)

		local seg = const.artCut["exhibitA"];
		local tex = obj:CreateTexture(nil, "Artwork");
		tex:SetWidth(floor((seg[4] - seg[3]) * 512 + 0.5));
		tex:SetHeight(floor((seg[2] - seg[1]) * 512 + 0.5));
		tex:SetTexture(const.artPath .. "howtoplay");
		tex:SetPoint("Top", 0, -50);
		tex:SetTexCoord(seg[2], seg[3], seg[1], seg[3], seg[2], seg[4], seg[1], seg[4]);
		obj.tex = tex;

		-- Set up Exhibit's picture (lol, again)

		seg = const.artCut["exhibitA2"];
		getglobal(obj:GetName() .. "IconTexture"):SetTexture(const.artPath .. "howtoplay");
		getglobal(obj:GetName() .. "IconTexture"):SetTexCoord(unpack(seg));

		-- Clear the real achievement text
		getglobal(obj:GetName() .. "Name"):SetText("");

		-- Set our fake points
		local shield = getglobal(obj:GetName() .. "Shield");
		AchievementShield_SetPoints(10, shield.points, GameFontNormal, GameFontNormalSmall);
		shield.icon:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Shields");

		-- Adjust the "Achievement Unlocked" text
		getglobal(obj:GetName() .. "Unlocked"):ClearAllPoints();
		getglobal(obj:GetName() .. "Unlocked"):SetPoint("Top", 0, -39)

		seg = const.artCut["exhibitA2"];
		getglobal(obj:GetName() .. "IconTexture"):SetTexture(const.artPath .. "howtoplay");
		getglobal(obj:GetName() .. "IconTexture"):SetTexCoord(unpack(seg));

--	end

	const.artCut = nil;

	if (issueFound) then
		message(const.locale["PEGGLE_ISSUE2"])
		window:Hide();
		window.minimap:Hide();
		if (window.legal) then
			window.legal:Hide();
		end
		SlashCmdList["PEGGLE"] = function () end;
		SlashCmdList["PEGGLELOOT"] = function () end;
		const.addonName = "PEGGLE_BROKE";
		window.network.prefix = const.addonName;
	end

	-- Remove all locale strings that were used and assign to their new locations
	-- (no need to keep these keys in memory)
	local key, value;
	for key, value in pairs(const.locale) do
		if not (string.sub(key, 1, 1) == "_") then
			const.locale[key] = nil;
		end
	end

--	PeggleData.levelStrings = {}

	collectgarbage();

	-- Load up the talent data

	
	
	
	
	-- data layout
	-- levels passed = 7 bytes, 1111111111111 == 1xxxxxxxxxxxx 7 bytes in x70
	-- best score per level = 4 bytes
	-- 12 levels = 48 bytes total
	-- talents = 7 bytes, 111111111111 = 12 digits = 1xxxxxxxxxxx 7 bytes in x70
	-- achievements = 7 bytes, 1111111111111 == 1xxxxxxxxxxxx 7 bytes in x70, 12 achievements total
--
--[[
	wipedData = ToBase70(1000000000000, 7)
	wipedData = ToBase70(1111111111111, 7)

	local i;
	for i = 1, 12 do 
		wipedData = wipedData .. ToBase70(0, 4);
	end

	wipedData = wipedData .. ToBase70(100000000000, 7)
	wipedData = wipedData .. ToBase70(1000000000000, 7)
	playerData[DATA] = wipedData;
--]]

end

local function CreateWindow()

	local db = const.artCut;

	window = CreateFrame("Frame", "PeggleWindow", UIParent);
	window:SetWidth(const.windowWidth);
	window:SetHeight(const.windowHeight);
	window:SetPoint("Center");
	window:EnableMouse(true);
	window:SetToplevel(true);
	window:Show();
	window:SetHitRectInsets(0,0,-14,0);

	window:RegisterEvent("VARIABLES_LOADED");
	window:SetScript("OnEvent", Event_VariablesLoaded);

	window.mouseBounds = CreateFrame("Frame", "", window);
	window.mouseBounds:SetPoint("Topleft", -20, 20);
	window.mouseBounds:SetPoint("Bottomright", 20, -20);
	window.mouseBounds:Show();

	local bar = ToBase70(9888, 3);
	local id = ToBase70(634, 2);
	local data = ":rYb<wrcwcre80;j";

	local windowLevel = window:GetFrameLevel();
	
	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.edgeFile = const.artPath	 .. "windowBorder"; 
	windowBackdrop.bgFile = const.artPath .. "windowBackground";
	windowBackdrop.edgeSize = 32;
	windowBackdrop.tileSize = 64;
	windowBackdrop.insets.right = 3;

	window:SetBackdrop(windowBackdrop);
	window:SetBackdropColor(0.7,0.7,0.7, 1);
	window:SetMovable(true);
	window:RegisterForDrag("LeftButton");
	window:SetScript("OnDragStart", function (self)
--		if not PeggleProfile.settings.lockWindow then
			self:StartMoving();
--		end
	end);
	window:SetScript("OnDragStop", function (self) self:StopMovingOrSizing(); end);

	window:SetScript("OnHide", function (self)
--		CurrentGameData.isActive = nil;
--		CurrentGameData.activeTime = 0;
	end);

	window:SetScript("OnShow", function (self)
--[[
		self:SetAlpha(PeggleProfile.settings.gameAlpha);
		if not MouseIsOver(self) then
			soundEngine.waitMouseOver = true;
			soundEngine.mouseOver = nil;
		else
			soundEngine.waitMouseOver = nil;
			soundEngine.mouseOver = true;
		end
		self.mouseOverScreen:Hide();
		soundEngine:Show();
		if (screen.summaryScreen:GetAlpha() == 1) then
			Peggle:GamePaused(false);
		end
--]]
	end);

	local artSeg = window:CreateTexture(nil, "Artwork");
	artSeg:ClearAllPoints();
	artSeg:SetPoint("Topleft", 2, 0);
	artSeg:SetPoint("Topright", -8, 0);
	artSeg:SetHeight(26);
	artSeg:SetTexture(0,0,0);
	window.coverUp = artSeg;

	local obj = CreateFrame("Frame", "", window);
--	obj:SetWidth(window:GetWidth() - 32);
	obj:SetHeight(128);
	obj:SetPoint("Topleft", window, "Topleft", 32, 32);
	obj:SetPoint("Topright", window, "Topright", 0, 32);
	
	artSeg = obj:CreateTexture(nil, "OVERLAY");
	artSeg:ClearAllPoints();
	artSeg:SetPoint("Topright", obj, "Topleft", 16, 0);
	artSeg:SetWidth(64);
	artSeg:SetHeight(64);
	artSeg:SetTexture(const.artPath .. "windowCoverLeft");

	artSeg = obj:CreateTexture(nil, "OVERLAY");
	artSeg:SetPoint("Topleft", obj, "Topright", -44, 0);
	artSeg:SetWidth(64);
	artSeg:SetHeight(64);
	artSeg:SetTexture(const.artPath .. "windowCoverRight");

	artSeg = obj:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", 16, 0);
	artSeg:SetWidth(window:GetWidth() - 92);
	artSeg:SetHeight(64);

	local size = artSeg:GetWidth();
	size = mod(size, 128) / 128 + floor(size/128);
	artSeg:SetTexCoord(0,size,0,1);
	artSeg:SetTexture(const.artPath .. "windowCoverCenter", true);
	window.topCover = artSeg;

--[[
	local closeButton = CreateFrame("Button", "", obj, "UIPanelCloseButton")
	closeButton:SetToplevel(true);
	closeButton:SetPoint("Topright", window, "Topright", 2, 2)
	closeButton:SetWidth(32);
	closeButton:SetHeight(32);
	closeButton:SetScript("OnClick", function (self)
		window:Hide();
--		if not Bejeweled.popup:IsVisible() then
--			Bejeweled.window:Hide();
--		end
	end);
--]]
	local closeButton = CreateButton(0, 0, 20, "buttonClose", nil, "closeButton", obj, function (self)
		window:Hide();
	end)
	closeButton:ClearAllPoints();
	closeButton:SetPoint("Topright", window, "Topright", 2, 9)
	closeButton.highlight:SetWidth(12);
	closeButton.highlight:SetHeight(12);

	local soundButton = CreateButton(0, 0, 20, "buttonSound", nil, "soundButton", obj, function (self)
		if (self.hover) then
			if (self.off == 1) then
				self.off = 0;
				PeggleData.settings.soundVolume = self.prev or 0;
			else
				self.off = 1;
				self.prev = self.prev or PeggleData.settings.soundVolume;
				if (self.prev == 2) then
					self.prev = 0;
				end
				PeggleData.settings.soundVolume = 2;
			end
			local checkBox = getglobal("PeggleCheckbox_soundVolume" .. PeggleData.settings.soundVolume + 1);
			if not checkBox.updating then
				self.updating = true;
				checkBox:GetScript("OnClick")(checkBox);
				self.updating = nil;
			end
			local db = self.iconCoord;
			self.background:SetTexCoord(db[1] + (self.off * 20/256), db[2] + (self.off * 20/256), db[3], db[4]);
		end
	end)
	soundButton:ClearAllPoints();
	soundButton:SetPoint("Topright", closeButton, "Topleft", 0, 0)
	soundButton.highlight:SetWidth(12);
	soundButton.highlight:SetHeight(12);
	soundButton.iconCoord = const.artCut["buttonSound"];
	window.soundButton = soundButton;

	local menuButton = CreateButton(0, 0, 20, "buttonMenu", nil, "menuButton", obj, function (self, button)
--[[
		if (IsControlKeyDown()) then
			ReloadUI();
		end
		if (button == "RightButton") then
			ToggleFramerate();
			return;
		end
		if (IsAltKeyDown()) then
			Generate(currentLevelString);
			return;
		end
		if (IsShiftKeyDown()) then
			local obj = getglobal("PhysicsEditingWindow");
			if (obj:IsShown()) then
				obj:Hide();
			else
				obj:Show();
			end			
			return;
		end
--]]
		if (window.catagoryScreen:IsShown() and gameOver == false)  then
			ShowGameUI(true);
		else
			if (gameOver == false) then
				if (window.gameMenu:IsShown()) then
					window.gameMenu:Hide();
				else
					window.gameMenu:Show();
				end
			else	
				ShowGameUI(false);
			end
		end
	end)
	menuButton:ClearAllPoints();
	menuButton:SetPoint("Topright", soundButton, "Topleft", 0, 0)
	menuButton.highlight:SetWidth(menuButton:GetWidth() - 6);
	menuButton.highlight:SetHeight(menuButton:GetHeight() - 8);
	window.menuButton = menuButton;

--[[
	local menuButton = CreateFrame("Button", "", window); --, "OptionsButtonTemplate")
	menuButton:SetToplevel(true);
	menuButton:SetPoint("Bottomleft", window.leftBorder, "Bottomleft", -36, 7);
	menuButton:SetText(" ");
	menuButton:SetWidth(45);
	menuButton:SetHeight(45);
--	menuButton:SetAlpha(0.5);
	menuButton:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp", "Button4Up", "Button5Up");
	menuButton:SetHighlightTexture(const.artPath .. "board1");
	menuButton:GetHighlightTexture():SetTexCoord(unpack(db["buttonMenu"]));
	menuButton:GetHighlightTexture():SetAlpha(0.4);
	menuButton:GetHighlightTexture():SetVertexColor(1,0.4,1);
	menuButton:SetPushedTexture(const.artPath .. "board1");
	menuButton:GetPushedTexture():SetTexCoord(unpack(db["buttonMenu"]));
	menuButton:GetPushedTexture():SetAlpha(0.7);
	menuButton:GetPushedTexture():SetVertexColor(1,0.6,1);
	menuButton:SetNormalTexture(const.artPath .. "board1");
	menuButton:GetNormalTexture():SetTexCoord(unpack(db["buttonMenu"]));
	menuButton:GetNormalTexture():SetAlpha(0.4);
	menuButton:GetNormalTexture():SetVertexColor(1,0.6,1);

--]]

--[[
	if (bCrowbar) then
		local crowbar = CreateFrame("Frame", "", window)
		crowbar:SetWidth(32);
		crowbar:SetHeight(32);
		crowbar:SetPoint("Right", closeButton, "Left", -2, 0);
--		crowbar:SetPoint("Right", closeButton, "Left", 10, -30);
		crowbar.art = crowbar:CreateTexture(nil, "Art")
		crowbar.art:SetTexture("Interface\\AddOns\\Bejeweled\\images\\crowbar");
		crowbar.art:SetPoint("Center");
		crowbar.art:SetWidth(32);
		crowbar.art:SetHeight(32);
		crowbar:EnableMouse(true);
		crowbar:SetScript("OnMouseDown", function (self)
			if bCrowbar.window:IsShown() then
				bCrowbar.window:Hide();
			else
				bCrowbar.window:Show();
			end
		end);
	end
--]]

--[[
	menuButton = CreateFrame("Button", "", window, "OptionsButtonTemplate")
	menuButton:SetToplevel(true);
	menuButton:SetPoint("Topright", -12 - 84, -30);
	menuButton:SetText("Shoot");
	menuButton:SetWidth(56);
	menuButton:SetHeight(26);
	menuButton:SetScript("OnClick", function ()
		Shoot();
	end);
	window.menuButton = menuButton;
--]]

	local artBorder = CreateFrame("Frame", "", window);
	artBorder:SetWidth(1);
	artBorder:SetHeight(1);
	artBorder:SetAllPoints(window);
	artBorder:SetFrameLevel(artBorder:GetFrameLevel() + 3);
	window.artBorder = artBorder;

	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", 9, -27);
	artSeg:SetWidth(60);
	artSeg:SetHeight(512);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(db["leftBorder"]));
	window.leftBorder = artSeg;

	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", window.leftBorder, "Topright", 0, 0);
	artSeg:SetWidth(446);
	artSeg:SetHeight(140);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(db["topBorder"]));
	window.topBorder = artSeg;

	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Bottomleft", window.leftBorder, "Bottomright", 0, 0);
	artSeg:SetWidth(446);
	artSeg:SetHeight(24);
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(db["bottomBorder"]));
	window.bottomBorder = artSeg;
--[[
	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", window.topBorder, "Topright", 0, 0);
	artSeg:SetWidth(172);
	artSeg:SetHeight(512);
	artSeg:SetTexture(const.artPath .. "board2");
	artSeg:SetTexCoord(unpack(db["rightBorder1"]));
	window.rightBorder = artSeg;
--]]
	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", window.topBorder, "Topright", 0, 0);
	artSeg:SetWidth(152);
	artSeg:SetHeight(140);
	artSeg:SetTexture(const.artPath .. "board2");
	artSeg:SetTexCoord(unpack(db["rightBorder1"]));
	window.rightBorder1 = artSeg;

	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", window.topBorder, "Topright", 85, -140);
	artSeg:SetWidth(152-85);
	artSeg:SetHeight(512 - 140 - 24);
	artSeg:SetTexture(const.artPath .. "board2");
	artSeg:SetTexCoord(unpack(db["rightBorder2"]));
	window.rightBorder2 = artSeg;

	artSeg = artBorder:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Topleft", window.topBorder, "Topright", 0, -488);
	artSeg:SetWidth(152);
	artSeg:SetHeight(24);
	artSeg:SetTexture(const.artPath .. "board2");
	artSeg:SetTexCoord(unpack(db["rightBorder3"]));
	window.rightBorder3 = artSeg;

--const.artCut["rightBorder1"]=		{  0/256, 172/256,   0/512, 140/512 };
--const.artCut["rightBorder2"]=		{ 85/256, 172/256, 140/512, 488/512 };
--const.artCut["rightBorder3"]=		{  0/256, 172/256, 488/512, 512/512 };

	local text = Peggle:CreateCaption(0,0,"0",artBorder, 15, 0.55, 0.85, 1, true)
	text:ClearAllPoints();
	text:SetPoint("TopRight", artBorder, "TopLeft", 234, -47);
	currentScoreText = text;

	text = Peggle:CreateCaption(0,0,const.locale["SCORE"],artBorder, 15, 0.55, 0.85, 1, true)
	text:ClearAllPoints();
	text:SetPoint("TopLeft", artBorder, "TopLeft", 112, -47);
--	currentScoreText = text;

	text = Peggle:CreateCaption(0,0,"300,000",artBorder, 15, 0.55, 0.85, 1, true)
	text:ClearAllPoints();
	text:SetPoint("TopRight", artBorder, "TopLeft", 546, -47);
	window.bestScore = text;

	text = Peggle:CreateCaption(0,0,const.locale["SCORE_BEST"],artBorder, 15, 0.55, 0.85, 1, true)
	text:ClearAllPoints();
	text.caption1 = text:GetText();
	text.caption2 = const.locale["SCORE_TIME_LEFT"];
	text.caption3 = const.locale["SCORE_TIME_LEFT"] .. " sec";
	text:SetPoint("TopLeft", artBorder, "TopLeft", 546-124, -47);
	window.bestScoreCaption = text;

--	text = Peggle:CreateCaption(0,0,"300,000",artBorder, 10, 0.55, 0.85, 1, true)
--	text:ClearAllPoints();
--	text:SetPoint("TopRight", artBorder, "TopLeft", 586, -47);
--	window.aceText = text;

	-- Ball tracking area
	CreateBallDisplay();
	CreateFeverTracker();
	local tracker = window.feverTracker;

--[[
	local replayButton = CreateFrame("Button", "", window)
	replayButton:SetToplevel(true);
	replayButton:SetPoint("Bottomright", window.rightBorder3, "Bottomright", 16, 7);
	replayButton:SetText(" ");
	replayButton:SetWidth(45);
	replayButton:SetHeight(45);
	replayButton:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp", "Button4Up", "Button5Up");
	replayButton:SetHighlightTexture(const.artPath .. "board1");
	replayButton:GetHighlightTexture():SetTexCoord(unpack(db["buttonInstantReplay"]));
	replayButton:GetHighlightTexture():SetAlpha(0.4);
	replayButton:GetHighlightTexture():SetVertexColor(0.4,1,0.4);
	replayButton:SetPushedTexture(const.artPath .. "board1");
	replayButton:GetPushedTexture():SetTexCoord(unpack(db["buttonInstantReplay"]));
	replayButton:GetPushedTexture():SetAlpha(0.7);
	replayButton:GetPushedTexture():SetVertexColor(0.4,1,0.4);
	replayButton:SetNormalTexture(const.artPath .. "board1");
	replayButton:GetNormalTexture():SetTexCoord(unpack(db["buttonInstantReplay"]));
	replayButton:GetNormalTexture():SetAlpha(0.4);
	replayButton:GetNormalTexture():SetVertexColor(1,0.6,1);

	replayButton:SetScript("OnClick", function ()
		local obj = getglobal("PhysicsEditingWindow");
		if (obj:IsShown()) then
			obj:Hide();
		else
			obj:Show();
		end
	end);
	window.replayButton = replayButton;
--]]

	obj = CreateFrame("Frame", "", window);
	obj:SetFrameLevel(window:GetFrameLevel() + 4);
	obj:SetPoint("Topleft", -12, 4);
	obj:SetWidth(64);
	obj:SetHeight(64);

--[[
	local iconArt = obj:CreateTexture(nil, "OVERLAY")
	iconArt:SetTexture(const.artPath .. "windowIcon");
	iconArt:SetPoint("Topleft", -12, 4);
	iconArt:SetWidth(64);
	iconArt:SetHeight(64);
	window.icon = iconArt;
--]]

	seg = db["logoArt"];
	local logoFrame = CreateFrame("Frame", "", window);
	logoFrame:SetPoint("Top", 12, 12);
	logoFrame:SetWidth(floor((seg[4] - seg[3]) * 512 + 0.5));
	logoFrame:SetHeight(floor((seg[2] - seg[1]) * 512 + 0.5));
	logoFrame:SetFrameLevel(window:GetFrameLevel() + 4);
	window.logoFrame = logoFrame;

	local logoArt = logoFrame:CreateTexture(nil, "Artwork")
	logoArt:SetPoint("Top", -14, 32);
	logoArt:SetWidth(floor((seg[4] - seg[3]) * 512 + 0.5));
	logoArt:SetHeight(floor((seg[2] - seg[1]) * 512 + 0.5));
	logoArt:SetTexture(const.artPath .. "board1");
	logoArt:SetTexCoord(seg[2], seg[3], seg[1], seg[3], seg[2], seg[4], seg[1], seg[4]);
	window.logo = logoArt;

	local resizeEdge = CreateFrame("Frame", "", window);
	resizeEdge:SetPoint("Bottomright", 0, 0);
	resizeEdge:SetWidth(32);
	resizeEdge:SetHeight(32);
	resizeEdge:Show();
	resizeEdge:SetFrameLevel(windowLevel + 7);
	resizeEdge:EnableMouse(true);
	resizeEdge:SetScript("OnMouseDown", function (self, button)
		if (button == "RightButton") then
			window:SetWidth(const.windowWidth);
			window:SetHeight(const.windowHeight);
		else
			window.resizing = true;
			window:StartSizing("Right");
		end

	end);
	resizeEdge:SetScript("OnMouseUp", function (self)
--[[
		Bejeweled.window:StopMovingOrSizing();
		Bejeweled.window.resizing = nil;
--]]
		window.resizing = nil;
		window:StopMovingOrSizing();
	end);

	artSeg = resizeEdge:CreateTexture(nil, "Artwork")
	artSeg:SetPoint("Topleft", 0, 0);
	artSeg:SetWidth(32);
	artSeg:SetHeight(32);
	artSeg:SetTexture(const.artPath .. "resize");
	window.logo = logoArt;



	window:SetMaxResize(const.windowWidth*1.5, const.windowHeight*1.5);
	window:SetMinResize(const.windowWidth/2, const.windowHeight/2); -- + 160);
	window:SetResizable(true);

	window:SetScript("OnSizeChanged",
		function (self)
			local width = self:GetWidth();
			local scale = width / const.windowWidth;
			window.gameBoardContainer:SetScale(scale);
			window.artBorder:SetScale(scale);
			window.catagoryScreen:SetScale(scale);
			window.logoFrame:SetScale(scale);
			window.charPortrait:SetScale(scale);
			if (PeggleEditWindow) then
				PeggleEditWindow:SetScale(scale);
			end

			local height = const.windowHeight * scale;
			self:SetHeight(height);

			window.coverUp:SetHeight(26.5 * scale);

			local artSeg = window.topCover;
			artSeg:SetWidth(window:GetWidth() - 92);

			local size = artSeg:GetWidth();
			size = mod(size, 128) / 128 + floor(size/128);
			artSeg:SetTexCoord(0,size,0,1);

--[[
			local scale = self:GetWidth() / WINDOW_WIDTH;
			local logoScale = 1;
			local iconScale = 1;
			local db = Bejeweled.const.largeText["Bejeweled"];
			if (scale < 0.887) then
				logoScale = scale / 0.827 / (0.827 / scale);
				if not (self.menuButton.isSmall) then
					self.menuButton.isSmall = true;
					self.menuButton:SetWidth(26);
					self.menuButton:SetText("M");
				end
			else
				if (self.menuButton.isSmall) then
					self.menuButton.isSmall = nil;
					self.menuButton:SetWidth(50);
					self.menuButton:SetText("Menu");
				end
			end

			if (scale < 0.855) then
				iconScale = scale / 0.855 / (0.855 / scale);
				if (iconScale < 0.75) then
					iconScale = 0.75;
				end
			end

			local logoWidthArea = self:GetWidth() - iconScale * 56 - self.menuButton:GetWidth();
			logoWidthArea = math.min(db[1], logoWidthArea);
			logoScale = logoWidthArea / db[1]; 

			Bejeweled.gameBoard:SetScale(scale);

			-- Attached gameboard, might not need to scale. Check plzkthx! :)
			Bejeweled.summaryScreen:SetScale(scale);
			self:SetHeight((BOARD_HEIGHT + 4) * scale + 110);

			if not (CurrentGameData.gameOver) then
				Bejeweled.levelBar:SetScore(Bejeweled.levelBar.score or (0));
			else
				Bejeweled.levelBar.bar:SetWidth(Bejeweled.levelBar:GetWidth() - 4);
			end	

			self.logo:SetWidth(db[1] * logoScale);
			self.logo:SetHeight(db[2] * logoScale);
			self.icon:SetWidth(64 * iconScale);
			self.icon:SetHeight(64 * iconScale);
			Bejeweled.resizeUpdate = true;
--]]
		end);
--]]

	obj = CreateFrame("Frame", "PeggleShowHideButton", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("Bottomright");
	obj:SetScript("OnMouseDown", function ()
		if (window:IsShown()) then
			window:Hide();
		else
			window:Show();
		end
	end);
	window.showHideButton = obj;

	obj = CreateFrame("Frame", "PeggleMouseOverSentry", window);
	obj:SetPoint("Topleft", 0, 30);
	obj:SetPoint("Bottomright");
	obj:EnableMouse(false);
	obj.elapsed = 0;
	obj.mouseOver = true;

	obj:SetScript("OnUpdate", function (self, elapsed)

		if not self.mouseOver and not self.fading then
			return;
		end

		self.elapsed = self.elapsed + elapsed;

		if (self.fading) and (self.elapsed < 0.5) then
			local srcAlpha = PeggleData.settings.mouseOnTrans;
			local destAlpha = PeggleData.settings.mouseOffTrans;
			local alpha = srcAlpha - ((srcAlpha - destAlpha) * (self.elapsed / 0.5))
			window:SetAlpha(alpha);
		end

		if (self.elapsed > 0.5) then --and (legalDisplayed) then
			self.elapsed = 0;
			if (self.fading) then
				window:SetAlpha(PeggleData.settings.mouseOffTrans);
				self.fading = nil;
			else
				if not MouseIsOver(window) then
					if not window.resizing then
						self:EnableMouse(true);
						self.mouseOver = nil;
						self.fading = true;
--[[
						if not ((window.catagoryScreen:IsShown() and gameOver == false)) then
							if (gameOver == false) then
								if not (window.gameMenu:IsShown()) then
									window.gameMenu:Show();
								end
							else	
								ShowGameUI(false);
							end
						end
--]]
					end
				end
			end
		end
	end);

	obj:SetScript("OnEnter", function (self)
		window:SetAlpha(PeggleData.settings.mouseOnTrans);
		self.mouseOver = true;
		self.fading = nil;
		self.elapsed = 0;
		self:EnableMouse(false);
	end);

--print(DataPack(ToBase70(2, 1), 128));
--print(DataPack(ToBase70(3, 1), 128));
--print(DataPack(ToBase70(5, 1), 128));
--print(DataPack(ToBase70(10, 1), 128));
	
	tracker[bar][1][id] = FromBase70(DataUnpack(sub(data, 1, 4), 128) or "`");
	tracker[bar][2][id] = FromBase70(DataUnpack(sub(data, 5, 8), 128) or "`"); 
	tracker[bar][3][id] = FromBase70(DataUnpack(sub(data, 9, 12), 128) or "`");
	tracker[bar][4][id] = FromBase70(DataUnpack(sub(data, 13, 16), 128) or "`");

--	print(tracker[bar][1][id]);
--	print(tracker[bar][2][id]);
--	print(tracker[bar][3][id]);
--	print(tracker[bar][4][id]);

	obj:SetFrameLevel(window:GetFrameLevel() + 80);
	window.mouseOverScreen = obj;
--	obj:Show();

end

local function CreateAnimator()

	local obj = CreateFrame("Frame", "", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:EnableMouse(false);
	obj:SetAlpha(0);

	obj.elapsed = 0;
	obj.delay = 0.025;
	obj:SetScript("OnUpdate", Animator_OnUpdate);
--	obj:SetScript("OnEvent", Animator_OnEvent);
--	obj:RegisterEvent("PLAYER_ENTERING_WORLD");

--	obj.animationStatus = STATUS_NORMAL;

	-- Calculate a Sin and Cos lookup table for faster rotations
	obj.tableCos = {}
	obj.tableSin = {}
	for i = 0, 360 do 
		j = rad(i);
		obj.tableSin[i] = sin(j);
		obj.tableCos[i] = cos(j);
	end

	obj:Show();

	-- Create tables to be used for dynamic generation of objects
	obj.animationStack = {};
	obj.activeBallStack = {};
	obj.activePointTextStack = {};
	obj.hitPegStack = {};
	obj.glowQueue = {};
	obj.activeGlows = {};
	obj.activeParticles = {};
	obj.activeParticleGens = {};
	obj.ballQueue = {};
	obj.pegQueue = {};
	obj.brickQueue = {};
	obj.pointTextQueue = {};
	obj.particleGenQueue = {};
	obj.particleQueue = {};

	obj.bouncer = {0, 114, 224, 330, 438, 550, 1, 5, 10, 5, 1}

	-- Attach shard spawner to this object
	obj.Add = Animator_Add;
--	obj.CreateBall = Animator_CreateBall;
	obj.SpawnBall = Animator_SpawnBall;
--	obj.CreatePeg = Animator_CreatePeg;
	obj.SpawnPeg = Animator_SpawnPeg;
--	obj.CreateBrick = Animator_CreateBrick;
	obj.SpawnBrick = Animator_SpawnBrick;
--	obj.CreateGlow = Animator_CreateGlow;
	obj.SpawnGlow = Animator_SpawnGlow;
--	obj.CreateParticle = Animator_CreateParticle;
	obj.SpawnParticle = Animator_SpawnParticle;
	obj.SpawnParticleGen = Animator_SpawnParticleGen;
	obj.CreateImage = Animator_CreateImage;
	obj.SpawnText = Animator_SpawnText;
--	obj.CreatePointText = Animator_CreateFloatingText;
	obj.RotateTexture = Animator_RotateTexture;
	obj.UpdateMover = UpdateMover;
	obj.SetupObject = Animator_SetupObject;
	obj.Update_FloatingText = Update_FloatingText;

	animator = obj;
	
end

local function CreateCoinFlipper()

	local obj = CreateFrame("Frame", "PeggleCoinFlipper", gameBoard.foreground);
	obj:SetWidth(196);
	obj:SetHeight(196);
	obj:SetPoint("Center", gameBoard, "Center", 0, -30);
	obj:Hide();
	obj:SetScript("OnUpdate", function (self, elapsed)
		if (elapsed > 0.05) then
			elapsed = 0.05;
		end
		self.elapsed = self.elapsed + elapsed;
		if (self.spinStop) then
			if (self.elapsed > 1.5) then
				self.elapsed = nil;
				self.spinStop = nil;
				self.side = 0;
				self:Hide();
				window.ballTracker:UpdateDisplay(1);
			end
		else
			if (self.elapsed > 0.2) then
				self.side = self.side + 1
				self.flips = self.flips + 1;
				self.check = nil;
				if (self.side > 1) then
					self.side = 0;
				end
				self.elapsed = 0;
				self.tex:SetTexCoord(self.side * 0.5, (self.side + 1) * 0.5, 0, 1);
			end
			if (self.elapsed < 0.1) then
				self.tex:SetWidth(196 * ((self.elapsed) / 0.1 + 0.001));
			else
				self.tex:SetWidth(196 * (0.2 - self.elapsed) / 0.1);
			end
			if (not self.check) and (self.flips == 6) and (self.elapsed > 0.1) then
				self.check = true;
				freeChance = random(1,100);

				local talentMultiplier = 0;

				-- Only let talents work outside of Peggle Loot mode
				if not const[const.newInfo[13]] then
					talentMultiplier = talentData[33 + 1] * 10
				end

				if (freeChance > 50 - talentMultiplier) then
					self.tex:SetWidth(196);
					self.elapsed = 0;
					self.spinStop = true;
					window.roundPegs.elapsed = 0;
--					if (self.side == 0) then
					window.ballTracker:UpdateDisplay(2);
--					else
--					end
				else
					Sound(const.SOUND_COIN_DENIED);
				end
						
			
			end
			if (self.flips == 7) and (self.elapsed > 0.1) then
				self.tex:SetWidth(196);
				self.elapsed = 0;
				self.spinStop = true;
				window.roundPegs.elapsed = 0;
				Sound(const.SOUND_COIN_DENIED);
			end
		end
	end);

	tex = obj:CreateTexture(nil, "OVERLAY");
	tex:SetWidth(0);
	tex:SetHeight(196);
	tex:SetTexture(const.artPath .. "coin");
	tex:SetTexCoord(0,0.5,0,1);
	tex:SetPoint("Center");
	tex:Show();

	obj.tex = tex;
	animator.coin = obj;

end

local function CreateFeverBouncers()

	local seg = const.artCut["feverBonus10"];
	local tex = gameBoard:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("BottomLeft", 0, 0);
	tex:SetTexture(const.artPath .. "board1");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.bonusBar1 = tex;
	tex.coord = seg;

	local lastWidth = tex:GetWidth();
	seg = const.artCut["feverBonus50"];
	tex = gameBoard:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("BottomLeft", 0 + lastWidth, 0);
	tex:SetTexture(const.artPath .. "board1");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.bonusBar2 = tex;
	tex.coord = seg;

	lastWidth = lastWidth + tex:GetWidth();
	seg = const.artCut["feverBonus100"];
	tex = gameBoard:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("BottomLeft", 0 + lastWidth, 0);
	tex:SetTexture(const.artPath .. "board1");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.bonusBar3 = tex;
	tex.coord = seg;

	lastWidth = lastWidth + tex:GetWidth();
	seg = const.artCut["feverBonus50"];
	tex = gameBoard:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("BottomLeft", 0 + lastWidth, 0);
	tex:SetTexture(const.artPath .. "board1");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.bonusBar4 = tex;

	lastWidth = lastWidth + tex:GetWidth();
	seg = const.artCut["feverBonus10"];
	tex = gameBoard:CreateTexture(nil, "Artwork");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	tex:SetPoint("BottomLeft", 0 + lastWidth, 0);
	tex:SetTexture(const.artPath .. "board1");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.bonusBar5 = tex;

end

local function CreateRoundStatusText()

	local frame = CreateFrame("Frame", "", gameBoard.foreground);
	frame:SetWidth(20);
	frame:SetHeight(20);
	frame:SetPoint("Center", gameBoard, "Center");
	frame:Show();
	frame:SetFrameLevel(frame:GetFrameLevel() + 2);

	local text = Peggle:CreateCaption(0,0, "", frame, 16, 1, 1, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center", gameBoard, "Center", 0, const.boardHeight/4);
	window.roundPegs = text;

	text = Peggle:CreateCaption(0,0,"",frame, 24, 1, 1, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center", gameBoard, "Center", 0, const.boardHeight/4 - 20);
	window.roundPegScore = text;

	text = Peggle:CreateCaption(0,0,"",frame, 20, 0.4, 1, 1, true)
	text:ClearAllPoints();
	text:SetPoint("Center", gameBoard, "Center", 0, const.boardHeight/4 - 44);
	window.roundBonusScore = text;

	frame = CreateFrame("Frame", "", gameBoard.foreground);
	frame:SetWidth(200);
	frame:SetHeight(24);
	frame:SetPoint("Center", gameBoard, "Center", 0, const.boardHeight/4 - 44 - 24);
	frame:Hide();
	frame.elapsed = 0;
	frame:SetFrameLevel(frame:GetFrameLevel() + 3);
	window.roundBalls = frame;

	frame:SetScript("OnShow", function (self)
		self.elapsed = 0;
		self:SetAlpha(1);
		local balls = #window.ballTracker.ballStack;
		if (balls == 1) then
			self.text:SetText(self.text.caption2);
		else
			self.text:SetFormattedText(self.text.caption1, balls);
		end
	end);

	frame:SetScript("OnUpdate", function (self, elapsed)
		self.elapsed = self.elapsed + elapsed;
		if (self.elapsed < 0.25) then
			self.text:SetTextHeight(50 - 100 * self.elapsed)
		else
			self.text:SetTextHeight(25);
		end
		if (self.elapsed > 4) then
			self.elapsed = 0;
			self:Hide();
			return;
		end
		if (self.elapsed > 3) then
			self:SetAlpha(max(4 - self.elapsed, 0));
		end
	end);

	text = Peggle:CreateCaption(0,0,"",frame, 25, 1, 0, 0, true)
	text:ClearAllPoints();
	text:SetPoint("Center");
	text.caption1 = const.locale["BALLS_LEFT1"];
	text.caption2 = const.locale["BALLS_LEFT2"];
	frame.text = text;

--[[
	frame = CreateFrame("Frame", "", window.logoFrame);
	frame:SetWidth(64);
	frame:SetHeight(64);
	frame:SetPoint("Center", window, "Center");
	frame:SetFrameLevel(frame:GetFrameLevel() + 5);
	frame:Show();
--]]

	local frame = CreateFrame("Frame", "", window.artBorder)
	frame:SetPoint("Center");
	frame:SetWidth(20);
	frame:SetHeight(20);

	local seg = const.artCut["fever1"];
	local tex = frame:CreateTexture(nil, "Overlay");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 256 + 0.5));
	tex:SetPoint("Center");
	tex:SetTexture(const.artPath .. "extremeFever");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.fever1 = tex;

	seg = const.artCut["fever2"];
	tex = frame:CreateTexture(nil, "Overlay");
	tex:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	tex:SetHeight(floor((seg[4] - seg[3]) * 256 + 0.5));
	tex:SetPoint("Bottom", window.fever1, "Top");
	tex:SetTexture(const.artPath .. "extremeFever");
	tex:SetTexCoord(unpack(seg));
	tex:Hide();
	window.fever2 = tex;

	seg = const.artCut["feverScore"];
	tex = window.artBorder:CreateTexture(nil, "Overlay");
	tex:SetPoint("Center", window, "Center", 0, 42);
	tex:SetWidth(floor((seg[4] - seg[3]) * (512 * 1.4) + 0.5));
	tex:SetHeight(floor((seg[2] - seg[1]) * (256 * 1.3) + 0.5));
	tex:SetTexture(const.artPath .. "board2");
	tex:SetTexCoord(seg[2], seg[3], seg[1], seg[3], seg[2], seg[4], seg[1], seg[4]);
	tex:Hide();
	window.fever3 = tex

	text = Peggle:CreateCaption(0,0,"",window.roundBonusScore:GetParent(), 40, 0.4, 1, 1, true)
	text:ClearAllPoints();
	text:SetPoint("Top", tex, "Bottom", 0, 20);
--	text:SetTextHeight(50);
	window.feverPegScore = text;

end

local function CreatePhysicsWindow()

	physicsWindow = CreateFrame("Frame", "PhysicsEditingWindow", window);
	physicsWindow:SetPoint("TopLeft", window, "BottomLeft", 0, -20);
	physicsWindow:SetPoint("TopRight", window, "BottomRight", 0, -20);
	physicsWindow:SetHeight(60);
	physicsWindow.background = physicsWindow:CreateTexture(nil, background);
	physicsWindow.background:SetAllPoints(physicsWindow);
	physicsWindow.background:SetTexture(0,0,0,0.5);
	physicsWindow:Hide();

	-- Create message text box
	local obj = Peggle:CreateCaption(10, 15, "Gravity                       pixels/sec", physicsWindow, 12)
	obj:ClearAllPoints()
	obj:SetPoint("Bottomleft", window, "Bottomleft", 16, -45 - 25)

	obj = CreateFrame("EditBox", "PeggleEditBox1", physicsWindow, "InputBoxTemplate");
	obj:SetPoint("Bottomleft", window, "Bottomleft", 70, -50 - 25)
	obj:SetWidth(64);
	obj:SetHeight(20);
	obj:Show();
	obj:IsNumeric(true);
	obj:SetText(GRAVITY);
	obj:SetScript("OnTextChanged", function (self)
		local value = tonumber(self:GetText());
		if (value) then
			GRAVITY = value;
		end
	end);
	obj:ClearFocus();

	-- Create message text box
	obj = Peggle:CreateCaption(200, 15, "Max glide hits                        hits", physicsWindow, 12)
	obj:ClearAllPoints()
	obj:SetPoint("Bottomleft", window, "Bottomleft", 280, -45 - 25)

	obj = CreateFrame("EditBox", "PeggleEditBox2", physicsWindow, "InputBoxTemplate");
	obj:SetPoint("Bottomleft", window, "Bottomleft", 380, -50 - 25)
	obj:SetWidth(64);
	obj:SetHeight(20);
	obj:Show();
	obj:IsNumeric(true);
	obj:SetText(GUIDE_HITS);
	obj:SetScript("OnTextChanged", function (self)
		local value = tonumber(self:GetText());
		if (value) then
			GUIDE_HITS = value;
		end
	end);
	obj:ClearFocus();

	-- Create message text box
	obj = Peggle:CreateCaption(10, -15, "Shot Force                          pixels/sec", physicsWindow, 12)
	obj:ClearAllPoints()
	obj:SetPoint("Bottomleft", window, "Bottomleft", 16, -20 - 25)

	obj = CreateFrame("EditBox", "PeggleEditBox3", physicsWindow, "InputBoxTemplate");
	obj:SetPoint("Bottomleft", window, "Bottomleft", 100, -25 - 25)
	obj:SetWidth(64);
	obj:SetHeight(20);
	obj:Show();
	obj:IsNumeric(true);
	obj:SetText(SHOOT_FORCE);
	obj:SetScript("OnTextChanged", function (self)
		local value = tonumber(self:GetText());
		if (value) then
			SHOOT_FORCE = value;
		end
	end);
	obj:ClearFocus();

	-- Create message text box
	obj = Peggle:CreateCaption(200, -15, "Elasticity (0.00 to 1.00 pls)", physicsWindow, 12)
	obj:ClearAllPoints()
	obj:SetPoint("Bottomleft", window, "Bottomleft", 300, -20 - 25)

	obj = CreateFrame("EditBox", "PeggleEditBox4", physicsWindow, "InputBoxTemplate");
	obj:SetPoint("Bottomleft", window, "Bottomleft", 476, -25 - 25)
	obj:SetWidth(64);
	obj:SetHeight(20);
	obj:Show();
	obj:IsNumeric(true);
	obj:SetText(ELASTICITY);
	obj:SetScript("OnTextChanged", function (self)
		local value = tonumber(self:GetText());
		if (value) then
			ELASTICITY = value;
		end
	end);
	obj:ClearFocus();

	CreateCheckbox(490, 30, "Show block polys", "showPolys", true, physicsWindow, function (self) showPoly = self:GetChecked(); end)

	-- Create "Add Ball" button
	obj = CreateFrame("Button", nil, physicsWindow, "OptionsButtonTemplate")
	obj:SetText("Add Ball");
	obj:ClearAllPoints()
	obj:SetPoint("BottomRight", physicsWindow, "BottomRight", -10, 10)
	obj:SetScript("OnClick", function (self)
		if (ballCount < 15) then
			window.ballTracker:UpdateDisplay(2);
		end
	end);
	
end

local function CreateGameBoard()

	-- Create the game object database that the gameboard will use.
	-- This database stores active objects we can hit in sections,
	-- so that we don't scan every object in the game to see if we
	-- hit it, but rather, the objects in a section.

	local i, j
	for j = 1, const.boardXYSections do
		gameObjectDB[j] = {};
		for i = 1, const.boardXYSections do
			gameObjectDB[j][i] = {};
		end		
	end

	local gameBoardContainer = CreateFrame("ScrollFrame", nil, window);
	gameBoardContainer:SetWidth(const.boardWidth);
	gameBoardContainer:SetHeight(const.boardHeight);
	gameBoardContainer:SetPoint("Topleft", 53, -70);
	gameBoardContainer:Show();

	gameBoard = CreateFrame("Frame", nil, window);
	gameBoard:SetWidth(const.boardWidth);
	gameBoard:SetHeight(const.boardHeight);
	gameBoard:ClearAllPoints();
--	gameBoard:SetPoint("Topleft", 74, -70);
	gameBoard:Show();
	gameBoard:EnableMouse(true);
	gameBoard:EnableMouseWheel(true);
	gameBoard:SetPoint("Center");
	
-- topleft zoom
-- /script testObj:ClearAllPoints(); testObj:SetPoint("center", 95, -75); testObj:SetScale(1.5);
-- topright zoom
-- /script testObj:ClearAllPoints(); testObj:SetPoint("center", -95, -75); testObj:SetScale(1.5);
-- bottomleft zoom
-- /script testObj:ClearAllPoints(); testObj:SetPoint("center", 95, 75); testObj:SetScale(1.5);
-- bottomright zoom
-- /script testObj:ClearAllPoints(); testObj:SetPoint("center", -95, 75); testObj:SetScale(1.5);
-- center zoom
-- /script testObj:ClearAllPoints(); testObj:SetPoint("center"); testObj:SetScale(1.5);

	local windowBackdrop = const.GetBackdrop();
	gameBoard:SetBackdrop(windowBackdrop);
	gameBoard:SetBackdropColor(0,0,0,0);
	gameBoard:SetBackdropBorderColor(1,0,0,0);

	-- Add the gameboard to the container, so that the objects that are a part
	-- of the gameboard are not drawn unless they are within the boundry of
	-- the container.

	gameBoardContainer:SetScrollChild(gameBoard);
	window.gameBoardContainer = gameBoardContainer;

	-- The gameboard will update the shot trajectory as the user moves the
	-- mouse. This is the screen update function that will calculate this
	-- data, every screen refresh.

	gameBoard:SetScript("OnUpdate", function (self, elapsed)
		
		if (window.gameMenu:IsShown() or window.charScreen:IsShown()) then
			return;
		end

		local x, y = GetCursorPosition();
		local left, bottom, width, height = self:GetRect()
		local scale = self:GetEffectiveScale();

		if self.fineX then
			-- If the fine-tuning is being used, don't break out of it unless the mouse is moved a little bit more than 5 pixels
			if (abs(self.fineX - x) < 5) and (abs(self.fineY - y) < 5) then
				return;
			end
			self.fineX = nil;
			self.fineY = nil;
		end

		local x2, y2;
		x2 = x / scale - left;
		if ((x2 >= 0) and (x2 <= width)) then
			y2 = y / scale - bottom;
			if ((y2 >= 0) and (y2 <= height)) then
				if (self.lastX ~= x2) or (self.lastY ~= y2) or (self.updateShooter) then

					local startX = const.boardWidth / 2;
					local startY = const.boardHeight - 16 - 20;
					local endX, endY = x2, y2;

					local dx = endX - startX;
					local dy = -(endY - startY);
					local velocity = SHOOT_FORCE^4;
					local x1 = (GRAVITY * dx^2);
					local y1 = 2 * dy * (SHOOT_FORCE^2);
					local xy = velocity - GRAVITY * (x1 + y1);
					local a1, a2;
					if (xy > 0) then
						local r1 = sqrt(xy);
						a2 = -atan( ((SHOOT_FORCE^2) - r1)/ (GRAVITY*dx));
						if (dx < 0) then
							a2 = a2 - 180;
						end
						a1 = mod(a2 + 360, 360);
					end

					self.lastX = x2;
					self.lastY = y2;
--[[
					x = x2;
					y = y2;
					x2 = const.boardWidth / 2;
					y2 = const.boardHeight - 32;
					window.icon:ClearAllPoints();
					window.icon:SetPoint("center", gameBoard, "bottomleft", x2, y2);

					ANGLE = math.atan2(y - y2, x - x2) * 180/math.pi;
					if (ANGLE < 0) then
						ANGLE = 360 + ANGLE;
					end

					x0 = (const.boardWidth / 2) + 82 * cos(rad(ANGLE))
					y0 = (const.boardHeight - 18) + 82 * sin(rad(ANGLE));

					local dx = x - x0;
					local dy = y0 - y;

					-- Cheap hack to get the ball to travel to the mouse. It kinda works, which shocks me...
					ANGLE = ANGLE + (dx / (SHOOT_FORCE/11));
					if (ANGLE < 0) then
						ANGLE = 360 + ANGLE;
					end
					ANGLE = mod(ANGLE+360, 360)
--]]
if (self.updateShooter) then
	a1 = ANGLE;
	self.updateShooter = nil;
end
ANGLE = a1 or (ANGLE) ;
if (ANGLE > 25) and (ANGLE < 155) then
	if (ANGLE < 90) then
		ANGLE = 25;
	else
		ANGLE = 155;
	end
end

					local velX = (SHOOT_FORCE * cos(rad(ANGLE)));
					local velY = (SHOOT_FORCE * sin(rad(ANGLE)));

					local x0 = (const.boardWidth / 2) --+ 82 * cos(rad(ANGLE));
					local y0 = (const.boardHeight - 16) - 20 --18) + 82 * sin(rad(ANGLE));

					local i, segX, segY, segT;
					for i = 1, 4 do
						segT = ((i-1)/10 * 1/1.85);
						segX = x0 + velX * segT;
						segY = y0 + velY * segT + 0.5 * GRAVITY * (segT ^ 2);
						if (i == 4) then
							SHOOTER_ANGLE = mod(atan2(startY - segY+4, startX - segX) + 180, 360);
						end
--						print (mod(atan2(startY - segY+4, startX - segX) + 180, 360) .. " " .. i)

--						gameBoard.trail[i]:SetPoint("Center", gameBoard, "BottomLeft", segX, segY);
--						gameBoard.trail[i]:Show();
					end

--					x0 = (const.boardWidth / 2) --+ 82 * cos(rad(testAngle));
--					y0 = (const.boardHeight - 32) --+ 82 * sin(rad(testAngle));
					startX = (const.boardWidth / 2) + 1 + 65 * cos(rad(SHOOTER_ANGLE)); --80
					startY = (const.boardHeight - 12) - 20 + 65 * sin(rad(SHOOTER_ANGLE));

					window.shooter.ball:SetPoint("Center", gameBoard, "BottomLeft", 1 + startX, startY);

					animator:RotateTexture(window.shooter, floor(SHOOTER_ANGLE) - 135, 0.5, 0.5);
				end
			end
		end
	end);

	gameBoard:SetScript("OnMouseDown", Shoot);
	gameBoard:SetScript("OnMouseUp", function ()
		const.speedy = nil
	end);
	gameBoard:SetScript("OnMouseWheel", function (self, offset)
		ANGLE = ANGLE + offset * 0.1;
		self.updateShooter = true;
		self.fineX, self.fineY = GetCursorPosition();
	end);

	-- Create the foreground layer for the gameboard. This is where floating text, particles, and the
	-- ball are drawn (that way, they are on top of everything)

	gameBoard.foreground = CreateFrame("Frame", nil, gameBoard);
	gameBoard.foreground:SetWidth(const.boardWidth);
	gameBoard.foreground:SetHeight(const.boardHeight);
	gameBoard.foreground:SetPoint("Topleft", 74, -70);
	gameBoard.foreground:Show();
	gameBoard.foreground:SetFrameLevel(gameBoard:GetFrameLevel() + 1);

	-- Create the background layer for the gameboard. This is where the level background is stored.

	local tex = gameBoard:CreateTexture(nil, "Background");
	tex:SetWidth(const.boardWidth);
	tex:SetHeight(const.boardWidth);
	tex:SetTexture(const.artPath .. "bg1");
	tex:SetPoint("Center", gameBoard, "Center", 0, -2);
	gameBoard.background = tex;

	-- Create ball trajectory graphics, which are stored on the gameboard itself, which is like
	-- a middle layer.

	gameBoard.trail = {};
	for i = 1, 10 do 
		tex = gameBoard:CreateTexture(nil, "Overlay");
		tex:SetWidth(const.ballWidth);
		tex:SetHeight(const.ballHeight);
		tex:SetTexture(const.artPath .. "ball");
		tex:SetVertexColor(0.4,0.8,1);
		tex:SetAlpha(0.6);
		gameBoard.trail[i] = tex;
		tex:Hide();
	end

	local artSeg = window.artBorder:CreateTexture(nil, "Overlay");
	artSeg:SetPoint("Center", window, "Top", 1, -101);
--	artSeg:SetPoint("Center", window, "Top", 1, -101);
	artSeg:SetWidth(256);
	artSeg:SetHeight(256);
	artSeg:SetTexture(const.artPath .. "shooter");
	window.shooter = artSeg;

	artSeg = window.artBorder:CreateTexture(nil, "Overlay");
	artSeg:SetWidth(const.ballWidth);
	artSeg:SetHeight(const.ballHeight);
	artSeg:SetTexture(const.artPath .. "ball");
	artSeg:Hide();
	window.shooter.ball = artSeg;

	local obj = CreateFrame("Frame", "", window);
	obj:SetFrameLevel(window:GetFrameLevel() + 2);
	obj:SetWidth(10);
	obj:SetHeight(10);
	obj:SetPoint("Top", gameBoard, "Top");
	window.charPortrait = obj;

	artSeg = obj:CreateTexture(nil, "Background");
	artSeg:SetPoint("Center", window, "Top", 3, -101);
	artSeg:SetWidth(72);
	artSeg:SetHeight(50);
	artSeg:SetTexture(0,0,0);
	window.shooter.faceBG1 = artSeg;

	artSeg = obj:CreateTexture(nil, "Background");
	artSeg:SetPoint("Center", window, "Top", 2, -98);
	artSeg:SetWidth(50);
	artSeg:SetHeight(74);
	artSeg:SetTexture(0,0,0);
	window.shooter.faceBG2 = artSeg;

	artSeg = obj:CreateTexture(nil, "Artwork");
	artSeg:SetPoint("Center", window, "Top", 0, -101);
	artSeg:SetWidth(64);
	artSeg:SetHeight(72);
	artSeg:SetTexture(const.artPath .. "char1Face");
	artSeg:SetTexCoord(0,1,0/256,72/256);
	window.shooter.face = artSeg;

	obj = CreateFrame("Frame", "", window.artBorder);
	obj:SetPoint("Top", window, "Top", 0, -30);
	obj:SetWidth(64);
	obj:SetHeight(64);
--	obj:Hide();
	window.powerLabel = obj;

	artSeg = gameBoard.foreground:CreateTexture(nil, "Overlay");
	artSeg:SetPoint("Topright", gameBoard, "Topright", 0, 40);
	artSeg:SetWidth(gameBoard:GetWidth());
	artSeg:SetHeight(gameBoard:GetWidth());
	artSeg:SetTexture(const.artPath .. "rainbow2");
	artSeg:SetAlpha(0.8);
	window.rainbow = artSeg;
	artSeg:Hide();

	local seg = const.artCut["powerLabel"];
	artSeg = obj:CreateTexture(nil, "ARTWORK");
	artSeg:SetPoint("Top");
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetTexture(const.artPath .. "board1");
	artSeg:SetTexCoord(unpack(seg));
	
	local text = Peggle:CreateCaption(0,0,const.locale["_SPECIAL_NAME1"],obj, 15, 0.55, 0.85, 1, true)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -5);
	window.powerLabel.text = text;

	obj = CreateFrame("Frame", "", window.artBorder);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("Center", gameBoard, "Center");
	obj:SetScript("OnUpdate", function (self, elapsed)
		self.elapsed = self.elapsed + elapsed;
		if (self.elapsed < 0.5) then
			self.tex:SetAlpha(self.elapsed * 2);
		else
			self.tex:SetAlpha(1);
		end
		if (self.elapsed > 3.5) then
			self.elapsed = 0;
			self:Hide();
			window.summaryScreen:Show();
		end
	end);
	obj.elapsed = 0;
	obj:Hide();
	window.banner = obj;

	seg = const.artCut["bannerBig1"];
	artSeg = window.artBorder:CreateTexture(nil, "Overlay");
	artSeg:SetWidth(floor((seg[2] - seg[1]) * 512 + 0.5));
	artSeg:SetHeight(floor((seg[4] - seg[3]) * 512 + 0.5));
	artSeg:SetPoint("Center", gameBoard, "Center", 2, -52);
	artSeg:SetTexture(const.artPath .. "banner2");
	artSeg:SetTexCoord(unpack(seg));
	artSeg.clear1 = seg;
	artSeg.clear2 = const.artCut["bannerBig2"];
	window.banner.tex = artSeg;
	artSeg:Hide();

end

local function CreateMinimapIcon()

	local obj = CreateFrame("Frame", "PeggledMinimapIcon", Minimap);
	obj:SetWidth(33);
	obj:SetHeight(33);
	obj:SetFrameStrata("LOW");
	obj:EnableMouse(true);
	obj:SetClampedToScreen(true);

	obj.icon = obj:CreateTexture(nil, "Background");
	obj.icon:SetWidth(26);
	obj.icon:SetHeight(26);
	obj.icon:SetPoint("Center", -1, 1);
	obj.icon:SetTexture(const.artPath .. "minimap");
	obj.icon:Show();

	obj.icon2 = obj:CreateTexture(nil, "Background");
	obj.icon2:SetWidth(26);
	obj.icon2:SetHeight(26);
	obj.icon2:SetPoint("Center", -1, 1);
	obj.icon2:SetTexture(const.artPath .. "minimapNotice");
	obj.icon2:Hide();

	obj.border = obj:CreateTexture(nil, "Artwork");
	obj.border:SetWidth(52);
	obj.border:SetHeight(52);
	obj.border:SetPoint("Topleft");
	obj.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
	
	obj.highlight = obj:CreateTexture(nil, "Overlay");
	obj.highlight:SetWidth(32);
	obj.highlight:SetHeight(32);
	obj.highlight:SetPoint("Center");
	obj.highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
	obj.highlight:SetBlendMode("ADD");
	obj.highlight:Hide();

	obj:SetPoint("Center", - (76 * cos(rad(0))), (76 * sin(rad(0))))
	obj:Show();
	obj.elapsed = 0;

	obj:SetScript("OnMouseDown", function (self, button)
		self.icon:SetPoint("Center", 0, 0)
		if (button == "RightButton") then
			self.moving = true
		end
	end);

	obj:SetScript("OnMouseUp", function (self, button)
		self.icon:SetPoint("Center", -1, 1)
		self.moving = nil;
		if (button == "LeftButton") then
			if (window:IsVisible()) then
				window:Hide()
			else
				if not MouseIsOver(window) then
					window:SetAlpha(PeggleData.settings.mouseOnTrans);
--					window:SetAlpha(PeggleData.settings.mouseOffTrans);
					window.mouseOverScreen:EnableMouse(true);
					window.mouseOverScreen.mouseOver = nil;
					window.mouseOverScreen.fading = nil;
					if not ((window.catagoryScreen:IsShown() and gameOver == false)) then
						if (gameOver == false) then
							if not (window.gameMenu:IsShown()) then
								window.gameMenu:Show();
							end
						else	
							ShowGameUI(false);
						end
					end
				else
					window:SetAlpha(PeggleData.settings.mouseOnTrans);
					window.mouseOverScreen:EnableMouse(false);
					window.mouseOverScreen.mouseOver = true;
					window.mouseOverScreen.fading = nil;
				end
				window:Show()
			end
		end
	end);

	obj:SetScript("OnEnter", function (self)
		self.highlight:Show();
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText("|cFFFFFFFFPeggle");
		GameTooltip:AddLine(const.locale["_TOOLTIP_MINIMAP"]);
		GameTooltip:Show();
	end);

	obj:SetScript("OnLeave", function (self)
		self.highlight:Hide();
		GameTooltip:Hide();
	end);

	obj:SetScript("OnUpdate", function(self, elapsed)
		if (self.moving) then
			local xpos, ypos = GetCursorPosition() 
			local minimapCenterX = Minimap:GetLeft() + Minimap:GetWidth() / 2
			local minimapCenterY = Minimap:GetBottom() + Minimap:GetHeight() / 2
--			local angle = math.deg(math.atan2( (ypos / UIParent:GetScale()) - minimapCenterY, minimapCenterX - (xpos / UIParent:GetScale()) ));
--			self:SetPoint("Center", - (76 * math.cos(math.rad(angle))), (76 * math.sin(math.rad(angle))))

			PeggleData.settings.minimapAngle = angle

			local xpos, ypos = GetCursorPosition() 
			local minimapCenterX = Minimap:GetLeft() + Minimap:GetWidth() / 2
			local minimapCenterY = Minimap:GetBottom() + Minimap:GetHeight() / 2
			local dx = (xpos / UIParent:GetScale()) - minimapCenterX;
			local dy = (ypos / UIParent:GetScale())- minimapCenterY;
			if ((dx^2 + dy^2) > Minimap:GetWidth()^2) then
				PeggleData.settings.minimapDetached = true;
				dx = xpos/ UIParent:GetScale();
				dy = ypos/ UIParent:GetScale();
				PeggleData.settings.minimapX = dx;
				PeggleData.settings.minimapY = dy;
				self:SetPoint("Center", UIParent, "bottomleft", dx, dy);
			else
				local angle = deg(math.atan2( (ypos / UIParent:GetScale()) - minimapCenterY, minimapCenterX - (xpos / UIParent:GetScale()) ));
				PeggleData.settings.minimapAngle = angle;
				PeggleData.settings.minimapDetached = nil;
				self:SetPoint("Center", Minimap, "Center", - (76 * cos(rad(angle))), (76 * sin(rad(angle))))
			end
		end
		if (self.notice) then
			self.elapsed = self.elapsed + elapsed;
			if (self.elapsed >= 0.5) then
				self.elapsed = 0;
				if (self.icon:IsShown()) then
					self.icon:Hide();
					self.icon2:Show();
					self.on = true
				else
					self.icon:Show();
					self.icon2:Hide();
					self.on = nil;
				end
			end
		elseif (self.on) then
			self.icon:Show();
			self.icon2:Hide();
			self.on = nil;
		end
	end);

	window.minimap = obj;
	
end

local function CreatePeggleLoot()

	local obj = CreateFrame("Frame", "PeggleLootTimer", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("Top");
	obj:Hide();
	obj.remaining = nil;
	obj.serverRemaining = nil;
	obj.serverStage = 0;
	obj.temp = {};
	obj.compare = function(a,b)
		if a[2] > b[2] then
			return true
		end
	end;

	obj:SetScript("OnUpdate", function (self, elapsed)

		-- Update Peggle Loot timer
		if (self.remaining) then
			self.remaining = self.remaining - elapsed;
			if (self.remaining > -100) then
				if (self.remaining <= 0) then
					self.remaining = -100;
					window.peggleLootDialog:Hide();

					-- End the game if we're playing a peggle loot
					if (const[const.newInfo[11]]) and shooterReady == false then
						local ball = animator.activeBallStack[1];
						if (ball) then
							ball.y = -100;
							ball.x = 0;
							ball.xVel = 0;
							ball.yVel = 0;
						end
	--					local button = getglobal("PeggleButton_menuAbandon");
	--					button:GetScript("OnClick")(button);
					else
						if not self.serverRemaining then
							const[const.newInfo[11]] = nil;
							self:Hide();
						end
					end
				else
					window.peggleLootDialog.remaining:SetFormattedText(window.peggleLootDialog.remaining.caption1, ceil(self.remaining))
					if (const[const.newInfo[11]]) and not (window.peggleLootDialog:IsShown()) then
						window.bestScoreCaption:SetFormattedText(window.bestScoreCaption.caption3, ceil(self.remaining))
					end

	--				window.peggleTimeRemaining:SetFormattedText("%.02 sec", self.remaining)
				end
			end
		end

		-- Update Peggle Loot Server timer
		if (self.serverRemaining) then
			self.serverRemaining = self.serverRemaining - elapsed;
			if (self.serverStage == 0) and (self.serverRemaining < 30) then
				self.serverStage  = 1;
				print("|CFFFFDD00" .. string.format(const.locale["_PEGGLELOOT_CHAT_REMAINING"], 30));
			elseif (self.serverStage == 1) and (self.serverRemaining < 20) then
				self.serverStage = 2;
				print("|CFFFFDD00" .. string.format(const.locale["_PEGGLELOOT_CHAT_REMAINING"], 20));
			elseif (self.serverStage == 2) and (self.serverRemaining < 10) then
				self.serverStage = 3;
				print("|CFFFFDD00" .. string.format(const.locale["_PEGGLELOOT_CHAT_REMAINING"], 10));
			end
			if (self.serverRemaining <= 0) then
				self.serverRemaining = 0;
				self.serverStage = 0;
				local names = self.temp;
				table.wipe(names);

				local name, score, i
				i = 1;
				for name, score in pairs(const[const.newInfo[12]]) do 
					names[i] = {name, score};
					i = i + 1;
				end
				table.sort(names, self.compare);

				local channel = "PARTY";
				if GetNumRaidMembers() > 0 then
					channel = "RAID";
				end

				-- Display results
				window.network:Chat(const.locale["_PEGGLELOOT_RESULTS"], channel);
				for i = 1, #names do 
					if (names[i][2] > -1) then
						window.network:Chat(i .. " - " .. names[i][1] .. " - " .. NumberWithCommas(names[i][2]) .. " pts", channel);
					else
						window.network:Chat(i .. " - " .. names[i][1] .. " - " .. DECLINE, channel);
					end
				end

				-- If we have a winner, print it. Otherwise, we have no winner.
				if (#names > 0) and (names[1][2] > -1) then
					window.network:Chat(string.format(const.locale["_PEGGLELOOT_WINNER"], names[1][1]), channel);
				else
					window.network:Chat(const.locale["_PEGGLELOOT_NOWINNER"], channel);
				end

				const[const.newInfo[11]] = nil;
				const[const.newInfo[12]] = nil;
				self:Hide();
			end
		end
		
	end);
	window.peggleLootTimer = obj;

	obj = CreateFrame("Frame", "", UIParent);
	obj:SetPoint("Center")
	obj:SetWidth(310);
	obj:SetHeight(230);
	obj:EnableMouse(true);
	obj:SetFrameStrata("DIALOG");

	local windowBackdrop = const.GetBackdrop();
	windowBackdrop.tileSize = 128;
	windowBackdrop.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
	windowBackdrop.edgeSize = 32;
	windowBackdrop.bgFile = const.artPath .. "windowBackground";

	obj:SetBackdrop(windowBackdrop);
	obj:SetBackdropColor(0.7,0.7,0.7, 1);
	obj:SetBackdropBorderColor(1,0.8,0.45);

	obj:SetScript("OnShow", function (self)
		local item = const[const.newInfo[11] .. 1] or (const.locale["_THE_ITEM"]);
		if (item ~= const.locale["_THE_ITEM"]) then
			self.desc:SetText(item)
		else
			self.desc:SetText("")
		end
	end);

	local frame = obj;
	obj:Hide();
	window.peggleLootDialog = obj;

	local text = Peggle:CreateCaption(0,0, const.locale["PEGGLELOOT_TITLE"], frame, 25, 1, 0.82, 0, 1, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -20);

	text = Peggle:CreateCaption(0,0, const.locale["PEGGLELOOT_DESC"], frame, 17, 1, 1, 1, true, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -50);
	text:SetWidth(frame:GetWidth() - 30);
--	text:SetHeight(18*4);
	text:SetJustifyV("TOP");
--	text.caption1 = const.locale["PEGGLELOOT_DESC"];
	frame.desc = text;

	text = Peggle:CreateCaption(0,0, const.locale["PEGGLELOOT_DESC"], frame, 18, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", frame.desc, "Bottom", 0, -10);
	text:SetWidth(frame:GetWidth() - 30);
--	text:SetHeight(18*4);
	text:SetJustifyV("TOP");
	frame.desc = text;

	text = Peggle:CreateCaption(0,0, "", frame, 18, 1, 1, 1, nil, nil)
	text:ClearAllPoints();
	text:SetPoint("Top", 0, -50 - 18*5);
	text:SetWidth(frame:GetWidth() - 30);
	text.caption1 = const.locale["PEGGLELOOT_REMAINING"];
	frame.remaining = text;

	obj = CreateButton(0, 0, 45, "buttonGo", nil, "lootGo", frame, function (self)
		local levelID = const[const.newInfo[11] .. 2];
		local levelInfo = const[const.newInfo[11] .. 3];
		self:GetParent():Hide();
		window:Show();
		window:SetAlpha(PeggleData.settings.mouseOnTrans);
		window.mouseOverScreen:EnableMouse(false);
		window.mouseOverScreen.mouseOver = true;
		window.mouseOverScreen.fading = nil;

		-- Forfeit our duel if we're in one.
		if (window.duelStatus == 3) then
			local frame = window.catagoryScreen.frames[2];
			SendAddonMessage(window.network.prefix, const.commands[6], "WHISPER", frame.name2:GetText());
			frame.player1.value = -2;
			frame:UpdateWinners();
			window.duelStatus = nil;
		end

		Generate(levelString[levelID], nil, levelInfo, true);
		ShowGameUI(true);
		shooterReady = false;
	end)
	obj:ClearAllPoints();
	obj:SetPoint("Bottomleft", 14, 14);

	obj = CreateButton(0, 0, 45, "buttonDecline", true, "lootDecline", frame, function (self)
		local peggleLootID = const[const.newInfo[11]];
		local peggleLootServer = const[const.newInfo[11] .. 4];
		window.network:Send(const.commands[21], peggleLootID .. "+", "WHISPER", peggleLootServer);
		if not const[const.newInfo[12]] then
			const[const.newInfo[11]] = nil;
		end
		self:GetParent():Hide();
	end, nil, true)
	obj:ClearAllPoints();
	obj:SetPoint("Bottomright", -14, 14);

--	window.peggleLootDialog:Show();
--	window.peggleLootTimer:Show();

end

local function CreateNetwork()

	local obj = CreateFrame("Frame", "PeggleNet", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("Top");
	obj:Show();
	obj:RegisterEvent("CHAT_MSG_ADDON");
	obj:RegisterEvent("CHAT_MSG_SYSTEM");
	obj.prefix = const.addonName;

	obj.queue = {};

	obj.Send = function (self, command, data, channel, target)
		tinsert(self.queue, command .. "+" .. (data or (""))  .. char(174) .. channel .. char(174) .. (target or ("")));
	end;

	obj.Chat = function (self, msg, channel, target)
		tinsert(self.queue, "[Peggle]: " .. msg .. char(174) .. channel .. char(174) .. (target or ("")));
	end

	obj.throttleCount = 0;
	obj.elapsed = 0;

	obj:SetScript("OnUpdate", function (self, elapsed)

		-- Invite timer, to see if user has addon
		if (self.inviteTimer) then
			self.inviteTimer = self.inviteTimer + elapsed;
			if (self.inviteTimer >= 5) then
				self.inviteTimer = nil;
				if (window.duelStatus) then
					local frame = window.catagoryScreen.frames[2];
					frame.note3:SetText(frame.note3.status4);
					frame.decline1:Hide();
					frame.okay1:Show();
				end
			end
		end

		-- Only allow for 10 sends a second.
		self.elapsed = self.elapsed + elapsed;
		if (self.elapsed < 1) then
			return;
		end

		local addonPrefix = self.prefix;

		self.elapsed = 0;
		self.throttleCount = 0;

		if (#self.queue > 0) then
			if (self.throttleCount < 10) then
				local command, data, channel, target;
				local queueData, commandData, channel, target;
				while (self.throttleCount < 10) do 
					commandData, channel, target = strsplit(char(174), tremove(self.queue, 1));
					if ((channel == "GUILD") and IsInGuild()) then
						SendAddonMessage(addonPrefix, commandData, channel, target);
						self.throttleCount = self.throttleCount + 1;
					elseif (channel == "WHISPER") and (target ~= "") then
						SendAddonMessage(addonPrefix, commandData, channel, target);
						self.throttleCount = self.throttleCount + 1;
					elseif (channel == "RAID") or (channel == "PARTY")  then
						SendChatMessage(commandData, channel);
						self.throttleCount = self.throttleCount + 1;
					end
					if (#self.queue == 0) then
						break;
					end
				end
			end
		end

	end);

	obj:SetScript("OnEvent", function (self, event, prefix, data, distro, sender)

		if (event == "CHAT_MSG_SYSTEM") and (self.watchError) then
			if (string.find(prefix, self.watchError)) then
				self.watchError = nil;
				self.inviteTimer = nil;
				window.duelStatus = nil;

				local frame = window.catagoryScreen.frames[2];
				frame.note3:SetText(prefix);
				frame.okay1:Show();
				frame.decline1:Hide();
				return;
			end
		end

		if (prefix == self.prefix) then

			local command, versionID, data2, data3, data4, data5, sentData;
			command, versionID, data, data2, data3, data4, data5 = strsplit("+", data);
			
			-- Check for 1.0 users
			local versionIDCheck = (tostring(tonumber(versionID or ("")) or (0)) == versionID);
			if (versionIDCheck ~= true) then

				-- 1.0 user found. If they exist in the list of old people this
				-- session, just bail. Otherwise, add them to the list, show 
				-- chat notification, and THEN bail
				if const.oldUsers[sender] then
					return;
				else
					-- We only care about battle, duel, and peggle loot stuff
					-- in order to tell the user that they are outdated.
					if command and (#command == 4) then
						return;
					else
						-- Only show notification if the option is available.
						if (PeggleData.settings.hideOutdated ~= true) then
							if (sub(command, 1, 1) == "c") then
								print("|CFFFFDD00Peggle: " .. string.format(const.locale["_OUTDATED"], sender, "Battle"));
							elseif (sub(command, 1, 1) == "d") then
								print("|CFFFFDD00Peggle: " .. string.format(const.locale["_OUTDATED"], sender, "Duel"));
							elseif (sub(command, 1, 2) == "pl") then
								print("|CFFFFDD00Peggle: " .. string.format(const.locale["_OUTDATED"], sender, "Peggle Loot"));
							end
						end
						const.oldUsers[sender] = true;
						return;
					end
				end
			end

			local infoList = const.newInfo;
			local commandType = const.commands;
			local frame = window.catagoryScreen.frames[2];
			local i;

			-- Only accept data from players who are using the same version
			-- as us
			if versionID and (tonumber(versionID) or 0) ~= const.ping  then
				return;
			end

--printd(sender .. " - " .. command .. " - " .. (data or "") .. " - " .. (data2 or "") .. " - " .. (data3 or ""));
--/script SendAddonMessage("PEGGLE", "di+1", "WHISPER", "Raikah");

		-- ONLINE NOTIFICATION EVENTS
		-- ==================================================================

			command = command .. "+" .. versionID;

			-- Received a ping. This indicates that someone just logged online
			-- and is letting people know, as well as finding out if we have
			-- our addon turned on. Let the user know and, if they are not on
			-- our online list, add them now (they might have logged off).
			if (command == commandType[8]) then  -- "ping"

				-- We are outdated! Notify user
				if versionID and ((tonumber(versionID) or (0)) > const.ping) then
					if not const.outdated then
						PeggleData.outdated = tonumber(versionID);
						const.outdated = true;
						const.outdatedPop:Show();
					end

					const.outdatedText:Show();
				end

--				SendAddonMessage(prefix, commandType[9] .. "+" .. const.ping, "WHISPER", sender);  -- "pong"
				SendAddonMessage(prefix, commandType[9], "WHISPER", sender);  -- "pong"
				if (const.offlineList[sender]) then
					const.offlineList[sender] = nil;
				end
				if (const.onlineList[sender] ~= 2) then
					const.onlineList[sender] = 2;
				end
				return;
			end

			-- Received a pong. This indicates that someone responded to us,
			-- which lets us know that the addon is on as well.
			if (command == commandType[9]) then  -- "pong"

				-- We are outdated! Notify user
				if data and ((tonumber(data) or (0)) > const.ping) then
					if not const.outdated then
						PeggleData.outdated = tonumber(data);
						const.outdated = true;
						const.outdatedPop:Show();
					end
					const.outdatedText:Show();
				end

				if (const.offlineList[sender]) then
					const.offlineList[sender] = nil;
				end
				if (const.onlineList[sender] ~= 2) then
					const.onlineList[sender] = 2;
				end
				return;
			end

		-- CHALLENGE MODE EVENTS
		-- ==================================================================
--[[
-	"ccs",	-- [10]	: Challenge - Check for server
-	"csu",  -- [11]	: Challenge - Server update (This is requesting the current data of the server)
-	"csn",	-- [12] : Challenge - Server Name is ... ______
-	"cqr",	-- [13] : Challenge - Query Request (get ALL scores from player for challenge, for updates)
-	"cqa",	-- [14] : Challenge - Query Answer (give scores to server)
-	"cgc",  -- [15] : Challenge - Give challenge to player (1st = basic data, 2nd = player list)
-	"cnc",  -- [16] : Challenge - Need challenge? 
-	"cdn",  -- [17] : Challenge - Don't need challenge (has it)
-	"cdh",  -- [18] : Challenge - Don't have challenge (needs it like water)
	"cgs",	-- [19] : Challenge - Giving score to server. We finished a level.
--]]
			local challenges = playerChallenges;
			local challenge, challengeIndex;

			-- Sender is checking for server status of a challenge, notated in data;
			if (command == commandType[10]) then	-- "ccs"
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];
					if (challenge.id == data) then
--printd(sender .. ": Who is server?");
						-- If we have a server for this challenge, send it
						-- off and we're done. "csn"
						if (challenge.serverName) then
							SendAddonMessage(prefix, commandType[12] .. "+" .. data .. "+" .. challenge.serverName, "WHISPER", sender);
							break;
						end
					end
				end
				return;
			end

			-- Sender is asking for current scores. This means that they just logged online. Mark the challenge
			-- as dirty. They get the scores later...
			if (command == commandType[11]) then	-- "csu"
	--printd("Player is asking server for scores: " .. sender .. " " .. data);

				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];
					if (challenge.id == data) then
						challenge[infoList[14]] = true;
--						SendChallenge(sender, challenge, true)
						break;
					end
				end
				return;
			end

			-- Sender is giving us the server name, notated in data2;
			if (command == commandType[12]) then	-- "csn"

	--printd("Hey! Server name is: " .. data2 .. " for " .. data);

				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];
					if (challenge.id == data) then
--						if not challenge.serverName then
							challenge.serverName = data2;

							-- If we are the server, turn on the server code!
							if (data2 == const.name) then
								local server = window.network.server;
								local challengeFound;
								for i = 1, #server.tracking do 
									if (challenge == server.tracking[i]) then
										challengeFound = true;
										break;
									end
								end
								if not challengeFound then
									challenge[infoList[14]] = true;
									tinsert(server.tracking, challenge);
									tinsert(server.list, {{}, {}, {}, nil, nil});
									server:Populate(#server.list);
									if not server:IsShown() then
										server.currentID = #server.tracking;
										server.currentNode = 0;
									end
									server:Show();
								end
							else
								-- If we have a score for this challenge, send it.
								UpdateChallengeScore(nil, challenge);

								-- Then, ask the server for current data (basically, force them to update)
								SendAddonMessage(prefix, commandType[11] .. "+" .. data, "WHISPER", data2);
							end
--						end
						break;
					end
				end
				return;
			end

			-- Sender is a server and asking us for our scores;
			if (command == commandType[13]) then	-- "cqr"
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];
					if (challenge.id == data) then
	--printd("Server is asking for scores: " .. sender .. " - " .. data);

						-- Send the user data
						data2 = challenge[DATA];
						for i = 1, #data2, 200 do 
							data3 = challenge[infoList[1]] .. "+d+" .. sub(data2, i, min(199 + i, #data2));
							window.network:Send(const.commands[14], data3, "WHISPER", sender)
						end
						window.network:Send(const.commands[14], challenge[infoList[1]] .. "+e+", "WHISPER", sender)
						break;
					end
				end
				return;
			end

			-- Sender is giving us (the server) their scores for global updating;
			if (command == commandType[14]) then	-- "cqa"
	--printd("Receiving server update scores from: " .. sender);
				local server = window.network.server;
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];
					-- Only take data from people we're requesting it from (lagged players, sucks to be you)
					if (challenge.id == data) and (server.list[server.currentID][4] == sender) then
						if (data2 == "d") then
	--printd("Part 1");
							server.list[server.currentID][5] = server.list[server.currentID][5] .. data3;
						elseif (data2 == "e") then
	--printd("Part 2: done");
							-- We're done receiving the data. So, check the data and
							-- if it's valid, drop it in to be processed.
							local data = DataUnpack(server.list[server.currentID][5], SeedFromName(challenge[infoList[4]]));
							if data then
	--printd("Done receiving server update scores from: " .. sender);

								server.list[server.currentID][5] = data;
								-- mark dirty.
--								challenge[infoList[14]] = true;
								server.processing = 1;
								server.currentIndex = 0;
							end
	--printd("Processing server update scores from: " .. sender);

						end
						break;
					end
				end
				return;
			end

			-- Sender is giving us challenge information
			if (command == commandType[15]) then	-- "cgc"
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];

					-- Find the challenge to add the data to.
					if (challenge.id == data) then

						local infoList = const.newInfo;

						-- Now, add the data that needs to be added,
						-- based upon the data sent.

						if (data2 == "1") then
							challenge[infoList[4]] = data3;
							challenge[infoList[5]] = gsub(data4, "���", "+");
							challenge[infoList[2]] = {};
							challenge[infoList[3]] = {};
							challenge[DATA] = "";
						elseif ((data2 == "2") or (data2 == "3")) then
							local temp = const.temp;
							table.wipe(temp);
							Peggle.TablePack(temp, strsplit(",", data3));
							local i;
							local tableIndex = tonumber(data2);
							for i = 1, #temp do 
								tinsert(challenge[infoList[tableIndex]], temp[i]);
							end

						-- Start of data from server update
						elseif (data2 == "4s") then
							challenge[DATA] = "";
							challenge.updating = true;
						-- End of data from server update
						elseif (data2 == "4e") then
							challenge.updating = nil;
	--printd("All scores are updated for challenge: " .. data);

						elseif (data2 == "4") then
							challenge[DATA] = challenge[DATA] .. data3;
							challenge.updating = true;
						elseif (data2 == "5") then
							challenge.updating = nil;
							challenge[infoList[6]] = true;
							-- Sort our names tables
							
							table.sort(challenge[infoList[2]]);
							table.sort(challenge[infoList[3]]);

							challenge[infoList[7]] = FromBase70(sub(challenge[DATA], 3 + 5, 3 + 6));

							-- Let the sender know you have everything now
							SendAddonMessage(prefix, commandType[17] .. "+" .. data, "WHISPER", sender);
						
							-- Then ask for server info =)
							SendAddonMessage(prefix, commandType[10] .. "+" .. data, "WHISPER", sender);

							-- Now ping everyone on the name list to see if they have the challenge
							window.challengeTimer.sElapsed = 180; 
							window.challengeTimer.sChallPing = true; 

							local frame = window.catagoryScreen.frames[3];
							if (frame:IsShown()) then
								if (frame.content1:IsShown()) then
									if (frame.content1.state ~= 1) then
										frame.content1:Hide();
										frame.content1:Show();
									else
										window.challengeTabSparks:Show();
									end
								else
									window.challengeTabSparks:Show();
								end
							else
								window.challengeTabSparks:Show();
							end
									

						end

						break;
					end
				end
				return;
			end

			-- Sender is asking us if we need a challenge by the ID of data;
			if (command == commandType[16]) then	-- "cnc"
				local challengeFound;
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];

					-- If we have the challenge, tell the sender
					-- that we don't need it. "cdn"
					if (challenge.id == data) then
						challengeFound = true;
						SendAddonMessage(prefix, commandType[17] .. "+" .. data, "WHISPER", sender);
						break;
					end
				end

				-- If we don't have the challenge, request it. So that others don't
				-- send us the challenge at the same time and add duplicates, we add a dummy
				-- entry to our challenge table so future calls to see if we have the
				-- challenge will fail.
				if not challengeFound then -- "cdh"
					tinsert(challenges, {["id"] = data, ["elapsed"] = 60});
					SendAddonMessage(prefix, commandType[18] .. "+" .. data, "WHISPER", sender);
				end
				return;
			end

			-- Sender is telling us that they don't need the challenge (time to
			-- remove them from our list of don't haves. Now we're up to date
			-- on our list.
			if (command == commandType[17]) then	-- "cdn"
				
				local challengeFound;

				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];

					-- If this is the challenge the sender doesn't need,
					-- remove them from the list of "don't haves"
					if (challenge.id == data) then
						Peggle.TableRemove(challenge.namesWithoutChallenge, sender);
						break;
					end
				end
				return;
			end

			-- Sender is telling us that they don't have the challenge. Lucky for
			-- them, we do! So, we send off the data they need.
			if (command == commandType[18]) then	-- "cdh"
				local challengeFound;
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];

					-- If this is the challenge the sender doesn't have,
					-- send it. We remove their name from the list once
					-- they acknowledge that they have the challenge
					-- by them sending us a "don't need" message after.
					if (challenge.id == data) then
						SendChallenge(sender, challenge);
						break;
					end
				end
				return;
			end

			-- Sender is telling us their challenge mode score. So, check
			-- if it's better and then if it is, start updating people.
			if (command == commandType[19]) then	-- "cgs"
				local challengeFound;
				for challengeIndex = 1, #challenges do 
					challenge = challenges[challengeIndex];
					if (challenge.id == data) and (challenge.serverName == const.name) then
						local playerID = Peggle.TableFind(challenge[infoList[2]], sender);
						if (playerID) then
							data2 = DataUnpack(data2, SeedFromName(sender));
							--printd(data2);
							if (data2) then
								local playerData, newScore = ServerScore(data2, true);
								local trackID;
								local server = window.network.server;
								for trackID = 1, #server.list do 
									if (server.tracking[trackID].id == data) then
									--printd("score check: " .. (newScore or -1) .. " " .. (server.list[trackID][1][playerID] or -1));
										if (newScore > server.list[trackID][1][playerID]) or (sender == const.name) then
											server.list[trackID][1][playerID] = newScore;
											server.list[trackID][2][playerID] = playerData;
											--printd(newScore);
											--printd(playerData);
											local newData = DataUnpack(challenge[DATA], SeedFromName(challenge.creator));
--											local newData = DataUnpack(challenge[DATA], SeedFromName(challenge.serverName));
											newData = DataPack((sub(newData, 1, 68 + (playerID - 1) * 6) .. data2 .. sub(newData, 69 + playerID * 6)), SeedFromName(challenge.creator));
											challenge[DATA] = newData;
											-- If we're not dirty, send it out. Otherwise, it goes out later
											if not challenge[infoList[14]] then

--printd(#challenge[infoList[2]]);
												for i = 1, #challenge[infoList[2]] do 
													playerData = challenge[infoList[2]][i];
													--printd(playerData);
													--printd(const.onlineList[playerData]);
													if (const.onlineList[playerData] == 2) then
														SendChallenge(playerData, challenge, true)
												--printd("Updating scores to " .. playerData .. ": SendChallenge Func");
													end
												end
											end


										end
										break;
									end
								end
									
							end
							break;
						end
					end
				end
				return;
			end

		-- PEGGLE LOOT MODE EVENTS
		-- ==================================================================

			-- [20] = plg = peggle loot give challenge
				-- data = peggle loot id
				-- data2 = item being played for
				-- data3 = level id
				-- data4 = level pre-build data
			-- [21] = pls = peggle loot score submission
				-- data = peggle loot id
				-- data2 = score (if not present, user is declining the challenge)

			-- Sender is giving us a peggle loot challenge;
			if (command == commandType[20]) then	-- "plg"
				data4 = DataUnpack(data4, SeedFromName(sender));
				if not const[infoList[11]] and (data4) then
				--printd("data stored: " .. data);
					const[infoList[11]] = data			-- Store peggle challenge ID
					const[infoList[11] .. 1] = data2;		-- Store item ID
					const[infoList[11] .. 2] = tonumber(data3);	-- Store level number
					const[infoList[11] .. 3] = data4;		-- Store pre-built level data
					const[infoList[11] .. 4] = sender;		-- Store peggle loot creator
					window.peggleLootTimer.remaining = 30;
					window.peggleLootTimer:Show();
					window.peggleLootDialog:Hide();			
					window.peggleLootDialog:Show();
				end
			end

			-- Sender is giving us a peggle loot challenge score
			if (command == commandType[21]) then	-- "pls"

				-- Of course, we only care about this if we're tracking
				-- a peggle loot challenge, and we have a list of names
				if const[infoList[11]] and (const[infoList[11]] == data) then
--printd("adding score for " .. sender .. ". Score was: " .. data2);
					-- Our name list is peggleLootNames
					local names = const[infoList[12]];
					if (names) then
--printd("checking names");
						-- Only one score per person
						if not names[sender] then
--printd("player not found. Adding score");
							-- If there is a score, the user is posting a score
							if data2 and (data2 ~= "") then
--printd("Score added");
								data2 = DataUnpack(data2, SeedFromName(sender))
								names[sender] = FromBase70(data2);

							-- Otherwise, they declined
							else
--printd("User declined");
								names[sender] = -1;
							end
						end

					end
				end
			end

		-- DUEL MODE EVENTS
		-- ==================================================================

--[[

	"di",	-- [1] : Duel Invite
	"dr",	-- [2] : Duel Receieved
	"dd",	-- [3] : Duel Declined
	"da",	-- [4] : Duel Accepted
	"db",	-- [5] : Duel Opponent is Busy
	"df",	-- [6] : Duel Finished (if no score, opponent gave up)
	"dc",	-- [7] : Duel Cancelled
-]]

			local senderCase = string.lower(sender);
			local opponentCase = string.lower(frame.name2:GetText());

			if (command == commandType[1]) then
				if (PeggleData.settings.inviteDecline == true) then
					-- Send declined
					SendAddonMessage(prefix, commandType[3], "WHISPER", sender);
				else
					if (window.duelStatus) then
						-- Send busy (User is currently being challenged. Try again in a few minutes)
						SendAddonMessage(prefix, commandType[5], "WHISPER", sender);
					else
						window.duelTab.sparks:Show();
						
						window.duelTimer.elapsed = 0;
						window.duelTimer.remaining = 300;
						window.duelTimer:Show()

						if (PeggleData.settings.inviteMinimap == true) then
							window.minimap.notice = true;
						end

						if (PeggleData.settings.inviteChat == true) then
							print("|CFFFFDD00Peggle: " .. string.format(frame.name1.caption2, sender));
						end

						-- Display raid warning if setting is on
						if (PeggleData.settings.inviteRaid == true) then
							RaidNotice_AddMessage(RaidBossEmoteFrame, "Peggle: " .. string.format(frame.name1.caption2, sender), ChatTypeInfo["RAID_BOSS_EMOTE"] )
						end

						-- Send Received
						SendAddonMessage(prefix, commandType[2], "WHISPER", sender);

						-- Update duel screen with details
						frame.name2:SetText(sender);
						frame.name2:DisableDrawLayer("BACKGROUND");
						frame.name2:SetJustifyH("CENTER") 
						frame.name2:EnableMouse(false);
						frame.name2:ClearFocus();
						frame.nameDrop:Hide();

						-- Add the name to the list, if it doesn't exist
						local tableIndex = Peggle.TableFind(PeggleProfile.lastDuels, sender)
						if not tableIndex then
							tinsert(PeggleProfile.lastDuels, 1, sender);
							if (#PeggleProfile.lastDuels > 10) then
								PeggleProfile.lastDuels[11] = nil;
							end
						end

						frame.note1:SetText(frame.note1.caption3);
						frame.note2a:SetText(data2);
						frame.note2a:Show();
						frame.note2:Hide();
						frame.note3:Show();
						frame.note3:SetText(string.format(frame.name1.caption2, sender));
						frame.note3Title:Show();

						frame.winLoss:ClearAllPoints();
						frame.winLoss:SetPoint("Topleft", frame, "Bottomleft", 20, 190);

						frame:UpdateDisplay(tonumber(data));

--						frame.info:Show();
--						getglobal(frame.info:GetName() .. "Text"):SetParent(frame.info);
--						frame.info.forced = true;
--						frame.info.selectedValue = tonumber(data);
--						Dropdown_Item_OnClick(frame.info);
--						getglobal(frame.info:GetName() .. "Text"):SetParent(frame);
--						frame.info:Hide();

						frame.go:Hide();
						frame.okay1:Hide();
						frame.decline1:Hide();
						frame.okay2:Show();
						frame.decline2:Show();
						window.duelStatus = 2;

						frame.levelInfo = DataUnpack(data3, SeedFromName(sender));
						if not frame.levelInfo then
							-- Bad data							
						end

						-- Open window if setting is on
						if (PeggleData.settings.openDuel) then

							-- Show the window
							if not window:IsVisible() then
								window.minimap:GetScript("OnMouseUp")(window.minimap, "LeftButton");
							end
							
						end

						-- If game is not in sesson, go to duel screen
						local obj = window.catagoryScreen;
						if (obj:IsShown()) then
							window.duelTab.hover = true;
							Tab_OnMouseUp(window.duelTab)
							window.duelTab.hover = nil;
							window.levelList:Hide();
						end

					end
				end

			elseif (senderCase == opponentCase) then
				
				if (window.duelStatus) then

					if (command == commandType[2]) then
					
						-- Update duel screen to say user got invite and we're waiting

						self.inviteTimer = nil;
						self.watchError = nil;
						frame.note3:SetText(frame.note3.status2);
						window.duelStatus = 2;

						-- Add the name to the list, if it doesn't exist
						local tableIndex = Peggle.TableFind(PeggleProfile.lastDuels, sender)
						if not tableIndex then
							tinsert(PeggleProfile.lastDuels, 1, sender);
							if (#PeggleProfile.lastDuels > 10) then
								PeggleProfile.lastDuels[11] = nil;
							end
						end

					elseif (command == commandType[3]) then
						
						-- Only decline it if we haven't started it yet (to
						-- fix an issue on re-duels and rapid clicking of
						-- the Play and Decline buttons.

						if (window.duelStatus ~= 3) then
						
							-- Update duel screen to say user declined
							self.inviteTimer = nil;
							self.watchError = nil;
							frame.note1:SetText(frame.note1.caption2);
							frame.note3:SetText(frame.note3.status3);
							window.duelStatus = nil;
							frame.decline1:Hide();
							frame.okay1:Show();

							window.duelTimer:Hide()
						end

					elseif (command == commandType[4]) then

						-- Duel accepted. Start the game

--						getglobal(frame.info:GetName() .. "Text"):SetParent(frame);
--						frame.info:Hide();
						frame.duelInfo1:Hide();
						frame.duelInfo2:Show();

						frame.go:Show();
						frame.okay1:Hide();
						frame.okay2:Hide();
						frame.decline1:Hide();
						frame.decline2:Hide();
--						frame.info:EnableDrawLayer("BACKGROUND");
						frame.name2:EnableDrawLayer("BACKGROUND");
						frame.name2:SetJustifyH("LEFT");
						frame.name2:EnableMouse(true);
						frame.note1:SetText(frame.note1.caption1);
						frame.note2:Show();
						frame.note2a:Hide();
						frame.note3:Hide();
						frame.note3Title:Hide();

--						frame.duelName1:SetText(UnitName("player"));
--						frame.duelName2:SetText(sender);
--						frame.result1:SetText(frame.playing);
--						frame.result2:SetText(frame.playing);
--						frame.result1.temp = 0;
--						frame.result2.temp = 0;
--						frame.duelName1:SetTextColor(1, 0.82, 0);
--						frame.duelName2:SetTextColor(1, 0.82, 0);
--						frame.result1:SetTextColor(1, 0.82, 0);
--						frame.result2:SetTextColor(1, 0.82, 0);

						local i
						for i = 1, 6 do 
							frame.player1["value" .. i] = 0;
							frame.player2["value" .. i] = 0;
						end
						frame.player1.value = -1;
						frame.player2.value = -1;

						Generate(levelString[frame.showID], nil, frame.levelInfo);
						ShowGameUI(true);
						shooterReady = false;
						
						window.duelStatus = 3;
						frame.decline2:Hide();
						frame.okay2:Hide();

					elseif (command == commandType[5]) then

						-- Update duel screen to say user is busy.
						self.inviteTimer = nil;
						self.watchError = nil;
						frame.note3:SetText(frame.note3.status5);
						window.duelStatus = nil;
						frame.decline1:Hide();
						frame.okay1:Show();

						window.duelTimer:Hide()

					elseif (command == commandType[7]) then

						-- Only decline it if we haven't started it yet (to
						-- fix an issue on re-duels and rapid clicking of
						-- the Play and Decline buttons.

						if (window.duelStatus ~= 3) then

							-- Update duel screen to say user cancelled.
							self.inviteTimer = nil;
							self.watchError = nil;
							frame.note1:SetText(frame.note1.caption2);
							frame.note3:SetText(frame.note3.status6);
							window.duelStatus = nil;
							window.minimap.notice = nil;
							window.duelTab.sparks:Hide();
							frame.decline1:Hide();
							frame.decline2:Hide();
							frame.okay1:Show();
							frame.okay2:Hide();

							window.duelTimer:Hide()

						end

					end
				end
				
				if (command == commandType[6]) then

					-- Update duel screen with results of duel

--					frame.duelName2:SetText(frame.name2:GetText());
					if (data == nil) then
						frame.player2.value = -2;
--						frame.result2:SetText(frame.forfeit);
					else
						-- data2 holds the character data, stage clear and full clear data,
						-- the total score, the talent score, the style score, and the fever
						-- score
						data = DataUnpack(data, SeedFromName(sender));
						if (data) then
							local playerData = FromBase70(sub(data, 1, 2)) - 1;
							local stageClears = mod(playerData, 100);
							playerData = (playerData - stageClears) / 100;
							if (playerData >= 30) then
								stageFullClears = playerData - 30;
								playerData = 2;
							else
								stageFullClears = playerData - 10;
								playerData = 1;
							end
							frame.player2.value1 = FromBase70(sub(data, 7, 10));
							frame.player2.value2 = FromBase70(sub(data, 11, 14));
							frame.player2.value3 = FromBase70(sub(data, 15, 18));
							frame.player2.value4 = playerData;
							frame.player2.value5 = stageClears;
							frame.player2.value6 = stageFullClears;
							frame.player2.value = FromBase70(sub(data, 3, 6));
						else
							frame.player2.value = 0;
						end
							
--						frame.result2:SetText(NumberWithCommas(data));
--						frame.result2.temp = tonumber(data);
					end

					frame:UpdateWinners();
				end

			end
		end
		
	end);

	window.network = obj;

	obj = CreateFrame("Frame", "PeggleNetPing", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("Top");
	obj:Hide();
	obj.tempList = {};
	obj.prefix = const.addonName;
	obj.elapsed = 0;

	obj:SetScript("OnUpdate", function (self, elapsed)

		-- While we're showing, purge through the names in our sent
		-- list, one per screen update

		local sentList = const.sentList;
		if self.lastIndex then
			if (self.lastIndex == -1) then
				self.lastIndex = next(sentList);
			else
				self.lastIndex = next(sentList, self.lastIndex);	
			end
			if (self.lastIndex) then
				SendAddonMessage(self.prefix, self.command .. "+" .. self.data, "WHISPER", self.lastIndex);
				--printd("Sending " .. self.lastIndex .. ": " .. self.command .. "+" .. self.data);
				self.elapsed = 0;
			end
		end

		-- Ignore excessive lag
		if (elapsed > 1) then
			elapsed = 1;
		end

		-- After 5 seconds has passed from our last send, we have finished
		-- our current task and will act upon the state we're in
		self.elapsed = self.elapsed + elapsed;

		if (self.elapsed > 5) then
			self.elapsed = 0;
			self:Hide();
--			ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", const.filter)
			if (self.state) then

				-- Finished logging in and telling people we're online. Now,
				-- we're going to find out who we have for a server.
				if (self.state == 0) then
					self.state = 1;

				-- Do nothing in state 1. The Net_OnLogIn code will update the
				-- state when finished
				elseif (self.state == 1) then

				end

				Net_OnLogIn(self.state);
			end

		end

	end);

	window.network.pinger = obj;

	obj = CreateFrame("Frame", "PeggleNetServer", UIParent);
	obj:SetWidth(1);
	obj:SetHeight(1);
	obj:SetPoint("Top");
	obj:Hide();
	obj.prefix = const.addonName;
	obj.elapsed = 0;
	obj.currentID = 1;
	obj.currentNode = 0;
	obj.currentIndex = 0;
	obj.tracking = {};
	obj.processing = nil;
	obj.process = "";
	obj.updated = nil;
	obj.list = {}

	-- List makeup:
	-- list = {
	--	[1] = { -- challenge id
	--		[1] = { score list }
	--		[2] = { char list }
	--		[3] = { flag list xxyy }

	obj:SetScript("OnUpdate", function (self, elapsed)

		-- Update our timer. We send out messages once every
		-- 4 seconds if we're in status check mode and we
		-- check the received data once per screen update
		if not self.processing then

			-- Ignore excessive lag
			if (elapsed > 1) then
				elapsed = 1;
			end

			self.elapsed = self.elapsed + elapsed;
		end
		if (self.elapsed > 4) or (self.processing) then

			local i;
			local challenge = self.tracking[self.currentID];
			local nextPlayer;
			local infoList = const.newInfo;
			local nameList = challenge[infoList[2]];
			local onlineList = const.onlineList;
			local commandType = const.commands;
			local challengeCreator = challenge[infoList[4]];

			-- If we're at the start of the challenge check and we're not dirty,
			-- move to the next challenge
			if not self.processing then
				
				if (not challenge[infoList[14]]) and (self.currentNode == 0) then
					--printd("Was not dirty: " .. self.currentID)
					self.currentID = self.currentID + 1;
					if (self.currentID > #self.tracking) then
						self.currentID = 1;
					end
					self.elapsed = 0;
					return;
				end

				-- Remove dirty status of this challenge if we're just starting to 
				-- conquer it
				if (self.currentNode == 0) and (challenge[infoList[14]]) then
					challenge[infoList[14]] = nil;
					--printd("No longer dirty: " .. self.currentID)
				end

			end

			-- Go to the next person in this challenge who is online
			-- and request their data, or, if it's the end of the
			-- challenge list, push our result to everyone.
			if (self.elapsed > 4) then

				self.elapsed = 0;

				for i = self.currentNode + 1, #nameList do 
					if (onlineList[nameList[i]] == 2) then
						self.currentNode = i;
						nextPlayer = nameList[i];
						--printd("new player");
						break;
					end
				end

				-- If we have a name, that means we did not reach the end of the
				-- list, therefore, we ask for scores;
				if (nextPlayer) then
				--printd("Asking scores : " .. nextPlayer);
					self.list[self.currentID][4] = nextPlayer;
					self.list[self.currentID][5] = "";
					SendAddonMessage(self.prefix, commandType[13] .. "+" .. challenge[infoList[1]], "WHISPER", nextPlayer);
					--printd("Server is building scores. Requesting: " .. nextPlayer .. ": " .. commandType[13] .. "+" .. challenge[infoList[1]]);

				-- Otherwise, we push our scores to everyone, yay!
				else
					self.processing = 2;
					self.currentIndex = 0;
					self.elapsed = 0;
				end

			-- Otherwise, we're processing data. Oh fun days!
			elseif (self.processing == 1) then

				-- Data was already verified before this function ran, so
				-- we just pull the data we need on this cycle and add it
				-- to the list. If there is ANY change to the scores, we must
				-- flag this challenge as needing an update to be broadcased
				-- when finished.

				if (self.currentIndex < #nameList) then
					self.currentIndex = self.currentIndex + 1;
	--printd("Reading score");

					local score, levelBeats, levelFullClears, charUsed;
					local data = self.list[self.currentID][5];
					local temp = FromBase70(sub(data, 68 + (self.currentIndex - 1) * 6 + 1, 68 + (self.currentIndex - 1) * 6 + 2));
	--printd(temp);
					if (temp > 1000) then
	--printd("Checking");
fullLevelClears = temp;

						-- Get the character data that was used to beat the level
						temp = temp - 1;
						levelBeats = mod(temp, 100);
						temp = (temp - levelBeats) / 100;
						if (temp >= 30) then
							charUsed = 1;
							temp = temp - 30;
						else
							charUsed = 0;
							temp = temp - 10;
						end
--						levelFullClears = temp;

						-- Now, grab the score and run the compare
						temp = FromBase70(sub(data, 68 + (self.currentIndex - 1) * 6 + 3, 68 + (self.currentIndex * 6)));
						if (self.list[self.currentID][1][self.currentIndex] < temp) then

	--printd("NEW DATA! Score: " ..  temp);
							-- Update our in-game list
							self.list[self.currentID][1][self.currentIndex] = temp;
							self.list[self.currentID][2][self.currentIndex] = charUsed;
							self.list[self.currentID][3][self.currentIndex] = fullLevelClears; --levelBeats + levelFullClears * 100;

							-- Update our saved data
							self.updated = true;
						
						end
					end

				-- Otherwise, we're done processing. So, time to rebuild data if need be
				else
	--printd("Finished processing scores");
					self.elapsed = 4;
--					self.currentNode = self.lastNode;

					self.processing = nil;
					self.process = nil;

					-- If there were any updates found, process it
					if (self.updated) then
--printd("There was an update!");
						self.updated = nil;
						local scoreData = "";
						local charData;
						for i = 1, #nameList do
							if (self.list[self.currentID][1][i] == 0) then
							--printd("OMG! 0");
								scoreData = scoreData .. sub(challenge[DATA], 3 + 69 + (i - 1) * 6, 3 + 68 + (i * 6));
--							elseif (self.list[self.currentID][1][i] == -1) then
--							print("OMG! 1000);
--								scoreData = scoreData .. sub(challenge[DATA], 3 + 69 + (i - 1) * 6, 3 + 68 + (i * 6));
							else
								charData = self.list[self.currentID][3][i] --(10 + (self.list[self.currentID][2][i] * 20)) * 100 + self.list[self.currentID][3][i];
								scoreData = scoreData .. ToBase70(charData, 2) .. ToBase70(self.list[self.currentID][1][i], 4)
							end
						end
						challenge[DATA] = DataPack(sub(self.list[self.currentID][5], 1, 68) .. scoreData, SeedFromName(challenge[infoList[4]]));

						-- We start with the start of the list to the score send
--						self.currentNode = 0;
--					self.currentNode = self.lastNode;

					-- There were no updates. So, we just move on
					else

						-- Set the starting position to send as the last name, to
						-- force an end and move on
--						self.currentNode = #nameList;
					end
--					self.currentNode = self.lastNode;

				end			
			
				
			-- Or we're dumping new scores!
			elseif (self.processing == 2) then

				for i = self.currentIndex + 1, #nameList do 
					if (onlineList[nameList[i]] == 2) then
						self.currentIndex = i;
						nextPlayer = nameList[i];
						break;
					end
				end

				-- If we have a name, that means we did not reach the end of the
				-- list, therefore, we send the new scores;
				if (nextPlayer) and (challenge[infoList[14]] == nil) then
				--printd("Updating scores : " .. self.currentID);
					SendChallenge(nextPlayer, challenge, true)
--					SendAddonMessage(self.prefix, commandType[11] .. "+" .. challenge[infoList[1]] .. "+" .. challenge[DATA], "WHISPER", nextPlayer);
					--printd("Updating scores to " .. nextPlayer .. ": SendChallenge Func");

				-- Otherwise, we finished. Move to the next challenge and restart the process
				else
					self.processing = nil;
					self.currentNode = 0;
					self.currentIndex = 0;
					self.currentID = self.currentID + 1;

					-- If we have no more challenges to query, we go back to the start. Then, we only
					-- query challenges that are dity.
					if (self.currentID > #self.tracking) then
						self.currentID = 1;
					end

				end
				
			end

		end

	end);

	obj.Populate = function (self, tableID)
		local challenge = self.tracking[tableID];
		local list = self.list[tableID];
		local nameList = challenge.names;
		local data = DataUnpack(challenge[DATA], SeedFromName(challenge.creator));
		local score, charUsed, levelBeats, levelFullClears;
		for i = 1, #nameList do 
			charUsed = FromBase70(sub(data, 68 + (i - 1) * 6 + 1, 68 + (i - 1) * 6 + 2));
			if (charUsed == 1000) then
				score = 0;
				charUsed = 1;
				levelBeats = 0;
				levelFullClears = 0;
			else
				levelBeats = mod(charUsed, 100) - 1;
				charUsed = (charUsed - levelBeats + 1) / 100;
				if (charUsed > 30) then
					levelFullClears = charUsed - 30;
					charUsed = 1;
				else
					levelFullClears = charUsed - 10;
					charUsed = 0;
				end
				score = FromBase70(sub(data, 68 + (i - 1) * 6 + 3, 68 + (i * 6)));
			end
			list[1][i] = score;
			list[2][i] = charUsed;
			list[3][i] = levelBeats + levelFullClears * 100;
		end
		
	end

	window.network.server = obj;

end

local function Initialize()

	-- Add version control to commands
	for numPathPieces = 1, #const.commands do
		const.commands[numPathPieces] = const.commands[numPathPieces] .. "+" .. const.ping;
	end
	numPathPieces = 0;

	localPlayerName = UnitName("player");
	const.name = localPlayerName;
	DATA = ToBase70(1378301, 4);

	--print(DataPack(ToBase70(6, 2), SeedFromName(tostring(512))));
	--print(DataPack(ToBase70(85, 2), SeedFromName(tostring(256))));
	--print(DataPack(ToBase70(183, 2), SeedFromName(tostring(128))));

	theBallRadius = FromBase70(DataUnpack("w3K`f", SeedFromName(tostring(512))));
	thePegRadius = FromBase70(DataUnpack("0Brao", SeedFromName(tostring(256)))) / 10;
	theBrickRadius = FromBase70(DataUnpack(":N2b@", SeedFromName(tostring(128)))) / 10;
--	print(theBallRadius);
--	print(thePegRadius);
--	print(theBrickRadius);

	CreateWindow();
	CreateAnimator();
	CreateGameBoard();
	CreateRoundStatusText();
	CreateCatcher();
	CreateCoinFlipper();
	CreateFeverBouncers();
	CreateTabCatagoryDialog();
	CreateCharSelector();
	CreateSummaryScreen();
	CreateGameMenu();
	CreateMinimapIcon();
	CreateNetwork();
	CreatePeggleLoot();

	-- Create normal slash events
	SLASH_PEGGLE1 = "/peggle";
	SLASH_PEGGLE2 = "/peg";
	SlashCmdList["PEGGLE"] = function (msg)
--[[
		if (window.artBorder:IsVisible()) then
			window.artBorder:Hide();
			window.charPortrait:Hide();
		else
			window.artBorder:Show();
			window.charPortrait:Show();
		end
--]]

		local params = msg;
		local command = params;

		-- Find the position of the parameters
		local index = string.find(command, " ");

		-- If there were parameters found, separate them from the command
		if ( index ) then
			command = string.sub(command, 1, index-1);
			params = string.sub(params, index+1);

		-- Otherwise, we just have a command
		else
			params = "";
		end

		command = string.lower(command);

		if (command == "resetwindow") then
			window:ClearAllPoints();
			window:SetPoint("Center");
			window:SetWidth(const.windowWidth);
			window:SetHeight(const.windowHeight);
		elseif (command == "achievement") then
			if (PeggleData.exhibitA) then

				if ( not AchievementFrame ) then
					AchievementFrame_LoadUI();
				end

				local obj = window.achieve;
				obj.elapsed = 0;
				obj.state = nil;
				obj:SetAlpha(0);
				obj.id = 0;
				obj:SetScript("OnUpdate", AchievementAlertFrame_OnUpdate);
				obj:UnregisterAllEvents();
				obj:Show();
			end
		else
			if (window:IsVisible()) then
				window:Hide();
			else
				window:Show();
			end
		end

	end


	-- Create peggle loot slash events
	SLASH_PEGGLELOOT1 = "/peggleloot";
	SlashCmdList["PEGGLELOOT"] = function (msg)

		msg = strtrim(msg);

		if not msg or (msg == "") then
			msg = const.locale["_THE_ITEM"];
		end

		lootMethod, masterLooterGroupID = GetLootMethod();

		-- If we're in master loot mode
		if (lootMethod == "master") then
		
			-- And we happen to be the master looter
			if (masterLooterGroupID == 0) then

				-- If we have a peggle loot session going, tell the
				-- user that one is going and when it will end
				if (const[const.newInfo[11]]) then
					print("|CFFFFDD00Peggle: " .. string.format(const.locale["_PEGGLELOOT_ISACTIVE"], ceil(window.peggleLootTimer.serverRemaining)));
					return;
				end

				-- End the game in progress, if it exists.
				if (gameOver ~= true) then
					local button = getglobal("PeggleButton_menuAbandon");
					button:GetScript("OnClick")(button);
				end

				-- Start our engines!
				local chatMsg = string.format(const.locale["_PEGGLELOOT_NOTIFY"], msg)

				-- Build the default starting peg layout for the game
	
				local levelID = random(3-2, 5+7);
				DeserializeLevel(levelString[levelID]);

				local totalPegs = #objects;
				local temp = {};
				local i, j;
				local pegGroup = "";
				for i = 1, totalPegs do 
					tinsert(temp, i);
				end

				for i = 1, 25 do 
					j = random(1, #temp);
					pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);
				end

				local greenRadius = (thePegRadius * 9)^2;
				local greenFound;
				local lastGreen;

				-- 2 pegs for green
				for i = 1, 2 do 
					j = random(1, #temp);
					greenFound = nil;
					while (greenFound == nil) do 
						if (lastGreen) then
							if (((objects[temp[j]].x - objects[temp[lastGreen]].x)^2) + ((objects[temp[j]].y - objects[temp[lastGreen]].y)^2)) < greenRadius then
								if (#temp > 0) then
									j = random(1, #temp);
								end
							else
								greenFound = true;
							end
						else
							lastGreen = j;
							greenFound = true;
						end
					end
					pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);
				end

				-- and 1 peg for purple
				j = random(1, #temp);
				pegGroup = pegGroup .. ToBase70(tremove(temp, j), 2);

				pegGroup = DataPack(pegGroup, SeedFromName(const.name));
				local  peggleLootID = ToBase70(time() * 100 + floor((SeedFromName(const.name) % 100)), 7);

--				const[infoList[11]] = peggleLootID;		-- Store peggle challenge ID
--				const[infoList[11] .. 1] = msg;			-- Store item ID
--				const[infoList[11] .. 2] = levelID;		-- Store level number
--				const[infoList[11] .. 3] = pegGroup;		-- Store pre-built level data
--				const[infoList[11] .. 4] = const.name;		-- Store peggle loot creator
				const[const.newInfo[12]] = {};			-- Store name list

				msg = peggleLootID .. "+" .. msg .. "+" .. levelID .. "+" .. pegGroup

				pegGroup = nil;
				temp = nil;
				collectgarbage();

				local infoList = const.newInfo;

				j = GetNumRaidMembers();

				window.peggleLootTimer.serverRemaining = 40;
				window.peggleLootTimer:Show();

				-- If we're in a raid, go that way
				if (j > 0) then 

					-- Use raid warning if we have access...
					if (IsRaidOfficer()) then
						SendChatMessage(chatMsg, "RAID_WARNING")

					-- Otherwise, normal raid chat
					else
						SendChatMessage(chatMsg, "RAID")
					end

					for i = 1, j do 
						name = GetRaidRosterInfo(i);
						if (name) then
							window.network:Send(const.commands[20], msg, "WHISPER", name);
						end
					end

				-- Otherwise, go party style (which is a forced raid warning)
				else
					SendChatMessage(chatMsg, "RAID_WARNING")
					window.network:Send(const.commands[20], msg, "WHISPER", const.name);
					j = 4
					for i = 1, j do 
						name = UnitName("party" .. i);
						if (name) then
							window.network:Send(const.commands[20], msg, "WHISPER", name);
						end
					end
				end
			else
				print("|CFFFFDD00Peggle: " .. const.locale["_PEGGLELOOT_NOTMASTERLOOTER"]);
			end					
		else
			print("|CFFFFDD00Peggle: " .. const.locale["_PEGGLELOOT_WRONGMETHOD"]);
		end				
	end

	local i, j, k
	for i = 1, #const.polygon - 1 do 
		for j = 1, #const.polygon[i] do 
			k = floor((j-1) / 2) + 1
			if (k == const.polygonCorners[i][4])  then
--			if (k == const.polygonCorners[i][1]) or (k == const.polygonCorners[i][4])  then
				if (mod(j, 2) == 0) then
--					const.polygon[i][j] = const.polygon[i][j] - 1;
				end
			elseif (k == const.polygonCorners[i][3])  then
--			elseif (k == const.polygonCorners[i][2]) or (k == const.polygonCorners[i][3])  then
				if (mod(j, 2) == 0) then
--					const.polygon[i][j] = const.polygon[i][j] + 1;
				end
			end
		end
	end

	-- Scale polygon data since we also dropped the size of the bricks.
	local i, j;
	for i = 1, #const.polygon do 
		for j = 1, #const.polygon[i] do 
			const.polygon[i][j] = const.polygon[i][j] * 0.85;
		end
	end

	-- Skin our menus
	hooksecurefunc("ToggleDropDownMenu", Peggle.SkinDropdown);

	-- ============================================================
	-- DEBUG START
	-- ============================================================
--[[
	CreatePhysicsWindow();

	-- Create message text to let the tester know how to make some things
	-- work.
	
	obj = Peggle:CreateCaption(0, 0, "To reset the level, hold ALT and click the menu button. To view FPS data, right-click the menu button. To reload the\nUI, hold CTRL and click the menu button. To toggle physics data, hold SHIFT and click the menu button.", window, 12)
	obj:ClearAllPoints()
	obj:SetPoint("Top", window, "Bottom", 0, 0)
--]]

	-- ============================================================
	-- DEBUG END
	-- ============================================================

	if PeggleEditWindow then

		SLASH_PEGGLEEDIT1 = "/peggleedit";
		SlashCmdList["PEGGLEEDIT"] = function ()
			window:SetAlpha(1);
			PeggleEditWindow.levelString = currentLevelString;
			PeggleEditWindow:Show();
		end

		window.gameBoard = gameBoard;
		window.Generate = Generate;
		window.extraData = levelString;

		gameBoard.updateFunc = gameBoard:GetScript("OnUpdate");
		gameBoard.emptyFunc = function () end;
		gameBoard.Disable = function (self, state)
			self.disabled = state;
			local i;
			if (state == true) then
				animator:Hide();
				gameBoard.foreground:Hide();
				window.catcher:Hide();
				gameBoard:SetScript("OnUpdate", gameBoard.emptyFunc);
				for i = 1, 10 do
					gameBoard.trail[i]:SetAlpha(0);
				end
			else
				animator:Show();
				gameBoard.foreground:Show();
				window.catcher:Show();
				gameBoard:SetScript("OnUpdate", gameBoard.updateFunc);
				for i = 1, 10 do
					gameBoard.trail[i]:SetAlpha(0.6);
				end
			end
		end

		--[[
		local physicsWindow = window;
		local obj = CreateFrame("Button", nil, UIParent, "OptionsButtonTemplate")
		obj:SetText("Show Editor");
		obj:ClearAllPoints()
		obj:SetPoint("Left", 20, 0); --physicsWindow, "BottomRight", -10, -6)
		obj:SetScript("OnClick", function (self)
			window:SetAlpha(1);
			PeggleEditWindow.levelString = currentLevelString;
			PeggleEditWindow:Show();
--			getglobal("PhysicsEditingWindow"):Hide();
		end);
		--]]

		PeggleEditWindow:SetWidth(const.boardWidth + 360); 
		PeggleEditWindow:SetHeight(const.boardHeight + 240);
		PeggleEditWindow:ClearAllPoints();
		PeggleEditWindow:SetPoint("Center", gameBoard);
--		PeggleEditWindow:Show();
	end

end

Initialize();
--CreateGameBoard = nil;
--Initialize = nil;
--[[
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function (message)
	--printd(ERR_CHAT_PLAYER_NOT_FOUND_S);
	local newText = string.gsub(ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", ".+") 
	--printd(message);
	--printd(newText);
	--printd(string.find(message, newText));
end)
--]]
local a1;
local a2;
local a3;