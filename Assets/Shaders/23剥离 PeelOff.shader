Shader "Jack Shaders/23剥离 PeelOff"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        u_ratio ("Ratio", Range(0, 1)) = 0
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
            fixed u_ratio;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            #define u_width 2000
            #define u_height 1125
            // 斜直线对于 x 的表达式
            float fx(float x)
            {
                return x - u_width + u_ratio * (u_height + u_width + 100.0);
            }
            // 斜直线对于 y 的表达式
            float gy(float y)
            {
                return y + u_width - u_ratio * (u_height + u_width + 100.0);
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed4 resColor = fixed4(u_ratio, 0.0, 0.0, 1.0);
                fixed4 texColor1 = tex2D(_MainTex, texCoord);
                fixed4 texColor2 = tex2D(_SecondTex, texCoord);
                
                // 转到画布真实的像素坐标系进行变换
                fixed2 coordRealScale = texCoord * fixed2(u_width, u_height);
                
                // 用二次函数，对揭开的边缘添加偏移
                float xNor = (coordRealScale.x - gy(0.0)) / (u_width - gy(0.0));
                float yNor = (coordRealScale.y - 0.0) / (fx(u_width) - 0.0);
                if (coordRealScale.x > gy(0.0) && coordRealScale.x < u_width)
                    coordRealScale.y = coordRealScale.y + 70.0 * xNor * (1.0 - xNor);
                if(coordRealScale.y > 0.0 && coordRealScale.y < fx(u_width))
                    coordRealScale.x = coordRealScale.x - 70.0 * yNor * (1.0 - yNor);
                
                // 沿 y = f(x) 翻转
                coordRealScale = fixed2(gy(coordRealScale.y), fx(coordRealScale.x));
                fixed2 coord = coordRealScale / fixed2(u_width, u_height);
                // 添加光影变化
                float intensityOffset = (1.0 - (1.0 - coord.x) * u_width / u_height - coord.y) + 2.0 * u_ratio - 0.1;
                // 揭开的背面的部分
                resColor = tex2D(_MainTex, coord) * intensityOffset;
                if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0)
                    resColor = texColor1;
                if(coordRealScale.y > fx(coordRealScale.x))
                    resColor = texColor2;
                return resColor ;
            }
            ENDCG
            
        }
    }
}
