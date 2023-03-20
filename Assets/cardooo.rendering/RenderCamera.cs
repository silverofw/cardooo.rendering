using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace cardooo.rendering
{
    [DisallowMultipleComponent, ExecuteAlways]
    [RequireComponent(typeof(Camera))]
    public class RenderCamera : MonoBehaviour
    {
        [SerializeField] public RenderProcess RenderProcess;
    }
}