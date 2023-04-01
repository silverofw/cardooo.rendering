using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEditor.PlayerSettings;

namespace cardooo.rendering
{
    [DisallowMultipleComponent, ExecuteAlways]
    [RequireComponent(typeof(Camera))]
    public class RenderCamera : MonoBehaviour
    {
        [SerializeField] public RenderProcess RenderProcess;

        public Vector3 pos;
    }
}