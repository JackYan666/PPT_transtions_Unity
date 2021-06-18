Shader "Jack Shaders/26门 Door"
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
                res = res - scaleCenter;
                res = res * (1.0 + zOffset);
                res = res + scaleCenter;
                
                res = res - thetaCenter;
                res.x = res.x / cos(theta);
                res.y = res.y / (1.0 - res.x * sin(theta));
                res.x = res.x / (1.0 - res.x * sin(theta));
                res = res + thetaCenter;
                
                res = res - xyOffset;
                return res;
            }
            
            fixed UVRange0_0Dot5(fixed2 bud2)
            {
                if (bud2.x < - 0.001 || bud2.x > 0.5001)
                    return 0.0;
                //else
                return 1;
            }
                        fixed UVRange0Dot5_1(fixed2 bud2)
            {
                if (bud2.x < 0.5001 || bud2.x > 1.0001)
                    return 0.0;
                //else
                return 1;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                float zOffset1 = -1.0 * u_ratio;
                fixed2 screenCenter = (0.5);
                fixed4 texColor1 = fixed4(0.0, 0.0, 0.0, 1.0);
                if(texCoord.x < 0.5)
                {
                    float theta = u_ratio * PI * 0.5;
                    fixed2 thetaCenter = fixed2(0.0, 0.5);
                    fixed2 coord1 = transform(texCoord, fixed2(0.0, 0.0), zOffset1, screenCenter, theta, thetaCenter);
                    if(coord1.x > 0.5)
                        coord1.x = 1.001;
                    if(UVRange0_0Dot5(coord1) > 0.1)
                        texColor1 = tex2D(_MainTex, coord1);
                }
                else
                {
                    float theta = -u_ratio * PI * 0.5;
                    fixed2 thetaCenter = fixed2(1.0, 0.5);
                    fixed2 coord1 = transform(texCoord, fixed2(0.0, 0.0), zOffset1, screenCenter, theta, thetaCenter);
                    if(coord1.x < 0.5)
                        coord1.x = -0.001;
                    if(UVRange0Dot5_1(coord1) > 0.1)
                        texColor1 = tex2D(_MainTex, coord1);
                }
                float zOffset2 = 0.5 * (1.0 - u_ratio);// zOffset从 0.5 -> 0，类似缩放因子从 0.5 -> 1
                fixed2 coord2 = transform(texCoord, fixed2(0.0, 0.0), zOffset2, fixed2(0.5, 0.5), 0.0, fixed2(0.0, 0.0));
                fixed4 texColor2 = 0.0;
                if (UVRange0_1(coord2) > 0.1)
                    texColor2 = tex2D(_SecondTex, coord2);
                if(coord2.x < 0.0 || coord2.x > 1.0 || coord2.y < 0.0 || coord2.y > 1.0)
                {
                    //texColor2 = fixed4(1.0); // window
                    texColor2 = (0.0); // door
                }
                return mix(texColor1, texColor2, u_ratio);
            }
            ENDCG
            
        }
    }
}
