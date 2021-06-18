Shader "Jack Shaders/22上拉帷幕 Prestige"
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
            
            
            #define PI 3.1415926
            // tent 函数，用于不同关键帧的线性插值
            float triFun(float x, float l, float c, float r)
            {
                if (l == c) l = c - 0.0001;
                if(r == c) r = c + 0.0001;
                float y1 = (x - l) / (c - l);
                float y2 = (x - r) / (c - r);
                return min(clamp(y1, 0.0, 1.0), clamp(y2, 0.0, 1.0));
            }
            float random(fixed2 st)
            {
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            fixed3 hash33(fixed3 p)
            {
                float n = sin(dot(p, fixed3(7, 157, 113)));
                return frac(fixed3(2097152, 262144, 32768) * n) * 2. - 1.;
            }
            
            float tetraNoise(in fixed3 p)
            {
                fixed3 i = floor(p + dot(p, (fixed3)(0.333333)));  p -= i - dot(i, (fixed3)(0.166666));
                fixed3 i1 = step(p.yzx, p), i2 = max(i1, 1.0 - i1.zxy); i1 = min(i1, 1.0 - i1.zxy);
                fixed3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
                fixed4 v = max(0.5 - fixed4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.0);
                fixed4 d = fixed4(dot(p, hash33(i)), dot(p1, hash33(i + i1)), dot(p2, hash33(i + i2)), dot(p3, hash33(i + 1.)));
                return clamp(dot(d, v * v * v * 8.) * 1.732 + .5, 0., 1.); // Not sure if clamping is necessary. Might be overkill.
            }
            float polynomialFun(float x, float p1, float p2, float p3, float p4, float p5, float p6)
            {
                return p1 * pow(x, 5.0)
                + p2 * pow(x, 4.0)
                + p3 * pow(x, 3.0)
                + p4 * pow(x, 2.0)
                + p5 * pow(x, 1.0)
                + p6 * pow(x, 0.0);
            }
            fixed3 transform(fixed2 texCoord)
            {
                fixed2 res = texCoord;
                float t1 = 0.0;
                float t2 = 0.35;
                float t3 = 1.0;
                res.y = res.y - clamp((u_ratio - t2) / (t3 - t2), 0.0, 1.0) - u_ratio * 0.1;
                // 加一个噪声函数，使之更有灵性
                float noise = tetraNoise(fixed3(texCoord, u_ratio * 3.0));
                
                // 变换的思想类似于：动画的关键帧，在关键时间点定义好变换形式，然后插值
                // 对 x 坐标的关键帧变换表达式
                float fx1_left = 0.0;
                float fx2_left = 0.03 * pow(1.0 - res.y, 2.0);
                float fx3_left = 0.1 + 0.25 * pow(1.0 - res.y, 2.0);
                float fx1_right = 1.0;
                float fx2_right = 1.0 - 0.03 * (1.0 - res.y);
                float fx3_right = 0.9 - 0.3 * (1.0 - res.y);
                // 对x的关键帧进行插值，使用 tent 函数
                float deltaX_left = 0.0;
                deltaX_left = triFun(u_ratio, t1, t1, t2) * (fx1_left)
                + triFun(u_ratio, t1, t2, t3) * (fx2_left)
                + triFun(u_ratio, t2, t3, t3) * (fx3_left);
                float deltaX_right = 1.0;
                deltaX_right = triFun(u_ratio, t1, t1, t2) * (fx1_right)
                + triFun(u_ratio, t1, t2, t3) * (fx2_right)
                + triFun(u_ratio, t2, t3, t3) * (fx3_right);
                // 对 x 坐标进行变换
                res.x = (res.x - deltaX_left) / (deltaX_right - deltaX_left) - 0.04 * noise * pow(u_ratio, 0.5);
                // 对 y 坐标的关键帧变换表达式
                float polynomialValue = polynomialFun(res.x, -6.407, 18.57, -18.76, 7.581, -0.98, 0.017);
                float polynomialGrandientValue = polynomialFun(res.x, 0.0, -6.407 * 5.0, 18.57 * 4.0, -18.76 * 3.0, 7.581 * 2.0, -0.98 * 1.0);
                float fy1_down = 0.0;
                float fy2_down = 0.1 * res.x * (1.0 - res.x) + 0.2 * polynomialValue - 0.05;
                float fy3_down = 0.3 * res.x * (1.0 - res.x) + 1.0 * polynomialValue;
                float fy1_top = 1.0;
                float fy2_top = 1.0 + 1.5 * res.x * (1.0 - res.x) - 0.1;
                float fy3_top = 1.0 + 0.6 * res.x * (1.0 - res.x);
                // 对y的关键帧进行插值，使用 tent 函数
                float deltaY_down = triFun(u_ratio, t1, t1, t2) * (fy1_down)
                + triFun(u_ratio, t1, t2, t3) * (fy2_down)
                + triFun(u_ratio, t2, t3, t3) * (fy3_down);
                float deltaY_top = triFun(u_ratio, t1, t1, t2) * (fy1_top)
                + triFun(u_ratio, t1, t2, t3) * (fy2_top)
                + triFun(u_ratio, t2, t3, t3) * (fy3_top);
                // 对 y 坐标进行变换
                res.y = (res.y - deltaY_down) / (deltaY_top - deltaY_down) ;
                res.y = res.y - 0.3 * noise * pow(u_ratio, 0.5);
                // 光影变化，和变换后的坐标一同返回
                float intensityOffset = 1.5 * polynomialGrandientValue * pow((deltaX_left + 1.0 - deltaX_right), 0.5);
                return fixed3(res, intensityOffset);
            }        
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed4 resColor = fixed4(1.0, 0.0, 0.0, 1.0);
                fixed4 texColor2 = tex2D(_SecondTex, texCoord);
                
                fixed3 res = fixed3(texCoord, 0.0);
                res = transform(texCoord);
                resColor = tex2D(_MainTex, res.xy);
                
                resColor = resColor * (1.0 + res.z);
                if (res.x < 0.0 || res.x > 1.0 || res.y < 0.0 || res.y > 1.0)
                    resColor = texColor2;
                return resColor ;
            }
            ENDCG
            
        }
    }
}
