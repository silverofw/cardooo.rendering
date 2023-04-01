using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.Rendering;

namespace cardooo.rendering
{
    public class Primitive2D
    {
        static uint s_Sheet;
        static List<Primitive.Batch> s_Batches0;
        static List<Primitive.Batch> s_Batches;
        static Matrix4x4[] s_ProjectionMatrices;

        static Primitive2D()
        {
            s_Sheet = 0;
            s_Batches0 = new List<Primitive.Batch>();
            s_Batches = new List<Primitive.Batch>();
            s_ProjectionMatrices = new[] {
                Matrix4x4.TRS(-Vector2.one, Quaternion.identity, new Vector3(2, 2, 1)),
                Matrix4x4.TRS(new Vector2(-1, 1), Quaternion.identity, new Vector3(2, -2, 1)),
            };
        }
        public static bool enabled
        {
            get { return Primitive.enabled; }
        }
        public static uint currentSheet
        {
            get { return s_Sheet; }
            set { s_Sheet = value; }
        }

        internal static void Swap()
        {
            Primitive.Swap(ref s_Batches0, ref s_Batches);

            foreach (var batch in s_Batches)
            {
                if (batch.managed)
                {
                    if (batch.material0 != null)
                    {
                        Primitive.ReleaseMaterial(batch.material0);
                    }
                    if (batch.material1 != null && batch.material0 != batch.material1)
                    {
                        Primitive.ReleaseMaterial(batch.material1);
                    }
                }
            }
            s_Batches.Clear();
        }

        internal static void Render(in ScriptableRenderContext context, Vector2Int resolution, bool flip)
        {
            if (!enabled)
            {
                return;
            }

            var cmd = CommandBufferPool.Get("Primitive2D");

            cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
            cmd.SetViewport(new Rect(0, 0, resolution.x, resolution.y));

            var projMatrix = s_ProjectionMatrices[flip ? 1 : 0];
            var resolutionMatrix = Matrix4x4.Scale(new Vector3(1.0f / resolution.x, 1.0f / resolution.y, 1));

            foreach (var batch in s_Batches0)
            {
#if UNITY_EDITOR
                // build的時候會出錯
                if (batch.mesh == null)
                {
                    continue;
                }
#endif
                if (batch.submesh >= 0)
                {
                    var matrix = batch.matrix;
                    matrix.m20 = matrix.m21 = 0;
                    matrix = projMatrix * matrix * resolutionMatrix;
                    matrix.m20 = batch.matrix.m20;
                    matrix.m21 = batch.matrix.m21;
                    cmd.DrawMesh(batch.mesh, matrix, batch.material0, batch.submesh, 0);
                }
                else
                {
                    var matrix = projMatrix * batch.matrix;
                    if (batch.material0 != null)
                    {
                        cmd.DrawMesh(batch.mesh, matrix, batch.material0, 0, 0);
                    }
                    if (batch.material1 != null)
                    {
                        cmd.DrawMesh(batch.mesh, matrix, batch.material1, 1, 0);
                    }
                }
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        static void Register(Primitive.Batch batch)
        {
            if (!enabled)
            {
                return;
            }

            s_Batches.Add(batch);
        }

        // pos: left-top viewport coordinate

        public static void DrawText(uint sheet, string text, in Vector2 pos, in Vector2 offset, float scale)
        {
            DrawText(sheet, text, pos, offset, scale, Color.white);
        }

        public static void DrawText(uint sheet, string text, in Vector2 pos, in Vector2 offset, float scale, in Color color)
        {
            DrawText(sheet, text, pos, offset, scale, color, Color.clear);
        }

        public static void DrawText(uint sheet, string text, in Vector2 pos, in Vector2 offset, float scale, in Color textColor, in Color bgColor)
        {
            if (!enabled || sheet != currentSheet)
            {
                return;
            }
            if (string.IsNullOrEmpty(text))
            {
                return;
            }

            var batch = new Primitive.Batch();
            batch.matrix = Primitive.GetTextMatrix(pos, scale);
            batch.mesh = Primitive.textMesh;
            batch.material0 = Primitive.AllocTextMaterial(offset, textColor, bgColor);
            batch.managed = true;
            batch.submesh = Primitive.RegisterText(text);

            Register(batch);
        }
    }
}
