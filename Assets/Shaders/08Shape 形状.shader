Shader "Jack Shaders/08Shape 形状"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        _Ratio ("Ratio", Range(0, 1)) = 0

        _SHAPE("SHAPE:CIRCLE=0, DIAMOND=1 ,PLUS=2",float)=0
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
            fixed _SHAPE;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 t1 = tex2D(_MainTex, i.uv);
                fixed4 t2 = tex2D(_SecondTex, i.uv);
                
                fixed2 texCoord=i.uv;
                fixed u_ratio=_Ratio;
                fixed  u_width=2048;
                fixed  u_height=1024;

                float w = 0.2;
                float alpha = 1.0;
                //int _SHAPE = 2; // 可选：CIRCLE 0 DIAMOND 1 PLUS 2
                if (_SHAPE == 0)
                    alpha = clamp((1.0 / w * sqrt(pow(texCoord.x - 0.5, 2.0) + pow((texCoord.y - 0.5) / u_width * u_height, 2.0))) + 1.0 + u_ratio * (-0.5 * sqrt(2.0) / w - 1.0), 0.0, 1.0);
                if(_SHAPE == 1)
                    alpha = clamp(abs(1.0 / w * (abs(texCoord.x - 0.5) + abs(texCoord.y - 0.5))) + 1.0 + u_ratio * (-0.5 * 2.0 / w - 1.0), 0.0, 1.0);
                if(_SHAPE == 2)
                    alpha = min(clamp(abs(texCoord.x / w - 0.5 / w) + 1.0 + u_ratio * (-0.5 / w - 1.0), 0.0, 1.0), clamp(abs(texCoord.y / w - 0.5 / w) + 1.0 + u_ratio * (-0.5 / w - 1.0), 0.0, 1.0));

                return mix(t1, t2, alpha) ;
            }
            ENDCG
            
        }
    }
}
