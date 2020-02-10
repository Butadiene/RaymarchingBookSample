Shader "Butadiene/raymarchRotSample"
{
	
		SubShader
	{
		Tags { "RenderType" = "Opaque"  "LightMode" = "ForwardBase" }
		LOD 100
		Cull Front
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
	
			float2 rot(float2 p,float r) {//回転のための関数
				float2x2 m = float2x2(cos(r),sin(r),-sin(r),cos(r));
				return mul(p, m);
			}

			float sphere(float3 p) //球の距離関数
			{
				return length(p) - 0.5;
			}
			
			float cube(float3 p) {//キューブの距離関数
				float3 s = float3(0.3,0.3,0.3);
				float3 q = abs(p);
				float3 m = max(s-q, 0.0);
				return length(max(q-s, 0.0)) - min(min(m.x, m.y), m.z);
			}
		
			float dist(float3 p) {//最終的な距離関数
				p.xy = rot(p.xy,1.0);
				return cube(p);
			}

			float3 getnormal(float3 p)//法線を導出する関数
			{
				float d = 0.0001;
				return normalize(float3(
					dist(p + float3(d, 0.0, 0.0)) - dist(p + float3(-d, 0.0, 0.0)),
					dist(p + float3(0.0, d, 0.0)) - dist(p + float3(0.0, -d, 0.0)),
					dist(p + float3(0.0, 0.0, d)) - dist(p + float3(0.0, 0.0, -d))
				));
			}


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 pos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			struct pout
			{
				fixed4 color : SV_Target;
				float depth : SV_Depth;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = v.vertex.xyz;//メッシュのローカル座標を代入
				o.uv = v.uv;
				return o;
			}


			pout frag(v2f i)
			{
				//以下、ローカル座標で話が進む
				float3 ro = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1)).xyz;//レイのスタート位置をカメラのローカル座標とする
				float3 rd = normalize(i.pos.xyz - ro);//メッシュのローカル座標の、視点のローカル座標からの方向を求めることでレイの方向を定義
		

				float d =0;
				float t=0;
				float3 p = float3(0, 0, 0);
				[unroll]//ループ展開
				for (int i = 0; i < 60; ++i) { //レイマーチングのループを実行
					p = ro + rd * t;
					d = dist(p);
					t += d;
					if (d < 0.001 || t>1000)break;//レイが遠くに行き過ぎたか衝突した場合ループを終える
				}
				p = ro + rd * t;
				float4 col = float4(0,0,0,1);
				if (d > 0.001) { //レイが衝突していないと判断すれば描画しない
					discard;
				}
				else {
					float3 normal = getnormal(p);
					float3 lightdir = normalize(mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz);//ローカル座標で計算しているので、ディレクショナルライトの角度もローカル座標にする
					float NdotL = max(0, dot(normal, lightdir));//ランバート反射を計算
					col = float4(float3(1, 1, 1) * NdotL, 1);//描画
				}

				pout o;
				o.color = col;
				float4 projectionPos = UnityObjectToClipPos(float4(p, 1.0));
				o.depth = projectionPos.z / projectionPos.w;
				return o;

			}
			ENDCG
		}

	}
}