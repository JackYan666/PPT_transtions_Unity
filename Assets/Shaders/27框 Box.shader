Shader "Jack Shaders/27框 Box"
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
            fixed2 transform(fixed2 texCoord, fixed2 xyOffset, float zOffset, fixed2 scaleCenter, float theta, fixed2 thetaCenter)
            {
                fixed2 res = texCoord;
                // xy 位移
                res = res - xyOffset;
                // z 位移，体现为缩放
                res = res - scaleCenter;
                res = res * (1.0 + zOffset);
                res = res + scaleCenter;
                // 旋转
                res = res - thetaCenter;
                res.x = res.x / (cos(theta) + 0.0001);
                res.y = res.y / (1.0 - res.x * sin(theta));
                res.x = res.x / (1.0 - res.x * sin(theta));
                res = res + thetaCenter;
                return res;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed2 screenCenter = fixed2(0.5, 0.5);
                fixed2 thetaCenter = fixed2(0.5, 0.5);
                
                float zOffset1 = (-abs(u_ratio - 1.0 / 3.0) + 1.0 / 3.0) * 0.5;
                fixed2 xyOffset1 = fixed2(-0.5 * u_ratio, 0.0);
                float theta1 = u_ratio * PI * 0.5;
                fixed2 coord1 = transform(texCoord, xyOffset1, zOffset1, screenCenter, theta1, thetaCenter);
                fixed4 texColor1 = 0.0;
                if (UVRange0_1(coord1) > 0.1)
                    texColor1 = tex2D(_MainTex, coord1);
                
                float zOffset2 = (-abs((1.0 - u_ratio) - 1.0 / 3.0) + 1.0 / 3.0) * 0.5;
                fixed2 xyOffset2 = fixed2(0.5 * (1.0 - u_ratio), 0.0);
                float theta2 = - (1.0 - u_ratio) * PI * 0.5;
                fixed2 coord2 = transform(texCoord, xyOffset2, zOffset2, screenCenter, theta2, thetaCenter);
                fixed4 texColor2 = 0.0;
                if(UVRange0_1(coord2) > 0.1)
                    texColor2 = tex2D(_SecondTex, coord2);
                
                return texColor1 + texColor2;
            }
            ENDCG
            
        }
    }
}
