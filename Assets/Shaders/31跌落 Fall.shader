Shader "Jack Shaders/31跌落 Fall"
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
            
            //#define u_width 2000
            //#define u_height 1125
            #define PI 3.1415926
            
            fixed2 transform(fixed2 texCoord, fixed2 xyOffset, float zOffset, fixed2 scaleCenter, float theta, fixed2 rotateCenter)
            {
                fixed2 res = texCoord;
                // 这个场景不需要 z 偏移，故可注去
                //res = res - scaleCenter;
                //res = res * (1.0 + zOffset);
                //res = res + scaleCenter;
                // 绕 x 轴旋转结合透视，体现为 x 轴方向的剪切，y轴方向的缩放和剪切，且添加了弯曲因素，使得图片看上去弯曲了
                res = res - rotateCenter;
                res.y = clamp(res.y / cos(theta), -0.5, 1.5);
                float yWrapFact = (0.3 * (1.0 - res.x) * u_ratio);// y 坐标的弯曲，与 x 呈线性变化，体现为左边低一些
                res.y = res.y * (1.0 + res.y * sin(theta) + yWrapFact);
                float xWrapFact = 0.2 * (1.1 - res.x) * u_ratio * sin((res.y + 0.2 * res.x + 0.1) * PI);// x 坐标的弯曲，用 sin 函数进行干扰
                res.x = res.x * (1.0 + (res.y * sin(theta) + xWrapFact));
                res = res + rotateCenter;
                // 这个场景不需要 xy 偏移，故可注去
                // res = res - xyOffset;
                return res;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed4 resColor = fixed4(1.0, 0.0, 0.0, 1.0);
                float zOffset1 = 0.0;
                fixed2 screenCenter = (0.5);
                fixed2 xyOffset = (0.0);
                fixed2 rotateCenter = fixed2(0.5, 0.0);
                // theta 是一个分段函数，用于控制坠落速度，先线性后三次函数
                float b = 0.001;
                float a = 0.2;
                float theta = b / a * u_ratio * PI * 0.5;
                if (u_ratio > a)
                    theta = (pow((u_ratio - a) / (1.0 - a), 3.0) * (1.0 - b) + b) * PI * 0.5;
                fixed2 coord1 = transform(texCoord, xyOffset, zOffset1, screenCenter, theta, rotateCenter);
                // 控制图片变暗的因子
                float fadeRatio = 1.0 - 0.5 * u_ratio;
                resColor = fadeRatio * tex2D(_MainTex, coord1);
                // 坠落图片意外的区域，显示第二张图
                if (coord1.x < 0.0 || coord1.x > 1.0 || coord1.y < 0.0 || coord1.y > 1.0)
                    resColor = tex2D(_SecondTex, texCoord);                
                
                return resColor;
            }
            ENDCG
            
        }
    }
}
