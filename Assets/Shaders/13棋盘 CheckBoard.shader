Shader "Jack Shaders/13棋盘 CheckBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        _Ratio ("Ratio", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets\Shaders\Tools\Tools.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            
            sampler2D _MainTex;
            sampler2D _SecondTex;
            fixed _Ratio;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            #define PI 3.1415926
            
            fixed2 transform(fixed2 texCoord, float theta, fixed2 axisPos, fixed2 gridNum)
            {
                fixed2 res = texCoord - axisPos;    // 从 axisPos 移动到 (0,0)
                // 执行旋转和投影（投影本质上是剪切）
                res.x = res.x / cos(theta);
                res.y = res.y / (1.0 - res.x * 2.0 * sin(theta));
                res.x = res.x / (1.0 - res.x * 2.0 * sin(theta));
                res = res + axisPos;    // 从 (0,0) 移动到 axisPos
                // 对超出棋盘格范围的坐标进行处理，设置为 -0.001 和 1.001 在 GL_CLAMP_TO_BORDER 模式下取背景色
                float halfGridWidth = 0.5 / gridNum.x;
                float halfGridHeight = 0.5 / gridNum.y;
                if (res.x < axisPos.x - halfGridWidth)        res.x = -0.001;
                if(res.x > axisPos.x + halfGridWidth)        res.x = 1.001;
                if(res.y < axisPos.y - halfGridHeight)        res.y = -0.001;
                if(res.y > axisPos.y + halfGridHeight)        res.y = 1.001;
                return res;
            }
            float random(fixed2 st)
            {
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            
            
            fixed4 frag(v2f i): SV_Target
            {
                float u_ratio = _Ratio;
                fixed2 texCoord = i.uv;
                
                fixed4 resColor = fixed4(0.0, 0.0, 0.0, 1.0);
                fixed2 gridNum = fixed2(7.0, 5.0);
                fixed2 axisPos = floor(texCoord * gridNum) * (1.0 / gridNum) + 0.5 / gridNum;
                float rotateTheta = clamp(u_ratio * (10.0 * random(axisPos) + gridNum.x * 8.0 * pow((1.0 - axisPos.x), 5.0)), 0.0, 1.0) * PI;
                
                fixed2 texCoordAfterTransform = transform(texCoord, rotateTheta, axisPos, gridNum);
                
                fixed4 texColor1 = tex2D(_MainTex, texCoordAfterTransform);
                // 对每个小块背面的坐标x进行翻转
                texCoordAfterTransform.x = floor(texCoordAfterTransform.x * gridNum.x + 1.0) / gridNum.x - texCoordAfterTransform.x + floor(texCoordAfterTransform.x * gridNum.x) / gridNum.x;
                fixed4 texColor2 = 0.0;
                
                if (UVRange0_1(texCoordAfterTransform) > 0.1)
                {                    
                    texColor2 = tex2D(_SecondTex, texCoordAfterTransform);
                    
                    if(rotateTheta <= 0.5 * PI)
                    {
                        float rotateThetaNor = rotateTheta * 2.0 / PI;
                        resColor = texColor1 * (1.0 - rotateThetaNor * 0.5) ;
                    }
                    else if(rotateTheta > 0.5 * PI)
                    {
                        float rotateThetaNor = (rotateTheta - 0.5 * PI) * 2.0 / PI;
                        resColor = texColor2 * (0.5 + rotateThetaNor * 0.5);
                    }
                }
                return resColor;
            }
            ENDCG
            
        }
    }
}
