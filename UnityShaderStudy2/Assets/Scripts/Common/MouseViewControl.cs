// **********************************************************************
// - FileName:          MouseViewControl.cs
// - Author:              #AuthorName#
// - CreateTime:       #CreateTime#
// - Email:                 #AuthorEmail#
// - Modifier:
// - Dscription:
// - (C)Copyright  
// - All Rights Reserved.
// **********************************************************************

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MouseViewControl : MonoBehaviour {
    public List<Transform> lookTatrget;
    public float upAngle = 90.0f;
    public float downAngle = -90.0f;
    public float leftAngle = -90.0f;
    public float rightAngle = 90.0f;
    public float minDistance = 5.0f;
    public float maxDistance = 30.0f;
    public bool needDamping = true;
    public float distanceDamp = 2.5f;
    public float angleDamp = 5.0f;

    private Vector3 target = Vector3.zero;
    private GameObject targetObject;
    private Camera camera;
    private float mouseScrollDistance = 0;
    private float mouseHorAngle = 0;
    private float mouseVerAngle = 0;
    private float distance = 0;

    private static MouseViewControl instance;
    public static MouseViewControl Instance {
        get {
            if (instance == null)
                instance = new MouseViewControl();
            return instance;
        }
    }

    private void Awake()
    {
        camera = Camera.main;
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void Start()
    {
        if (targetObject == null) {
            targetObject = new GameObject("TargetCenter");
            targetObject.transform.position = Vector3.zero;
            targetObject.transform.eulerAngles = Vector3.zero;
            targetObject.transform.localScale = Vector3.one;
        }
        SetTarget(lookTatrget,10,-135,45);
    }

    private Vector3 CalculateCenter(List<Transform> lookTargets) {
        Vector3 results = Vector3.zero;
        if (lookTargets != null) {
            int length = lookTargets.Count;
            for (int i = 0; i < length; i++) {
                results.x += lookTargets[i].position.x;
                results.y += lookTargets[i].position.y;
                results.z += lookTargets[i].position.z;
            }
            results.x /= length;
            results.y /= length;
            results.z /= length;
        }
        return results;
    }

    private Vector3 CalculateCameraEndPosition(float distance,float horAngle,float verAngle) {
        Vector3 cameraEndPosition = Vector3.zero;

        cameraEndPosition.x = target.x + distance * Mathf.Cos(Mathf.Deg2Rad * verAngle) * Mathf.Sin(Mathf.Deg2Rad * horAngle);
        cameraEndPosition.y = target.y + distance * Mathf.Sin(Mathf.Deg2Rad * verAngle);
        cameraEndPosition.z = target.z + distance * Mathf.Cos(Mathf.Deg2Rad * verAngle) * Mathf.Cos(Mathf.Deg2Rad * horAngle);

        return cameraEndPosition;
    }

    /// <summary>
    /// Camera Look at Targets by Time
    /// </summary>
    /// <param name="lookTargets">look targets</param>
    /// <param name="distance">look distance</param>
    /// <param name="horAngle">horizantal angle relative to target</param>
    /// <param name="verAngle">vertical angle relative to target</param>
    public void SetTarget(List<Transform> lookTargets,float distance,float horAngle,float verAngle) {
        target = CalculateCenter(lookTargets);
        targetObject.transform.position = target;
        Vector3 cameraEndPosition = CalculateCameraEndPosition(Mathf.Clamp(distance, minDistance, maxDistance), horAngle,verAngle);
        StartCoroutine(CameraToEndPosition(target,cameraEndPosition));
    }

    /// <summary>
    /// Camera Look at Targets by Time
    /// </summary>
    /// <param name="lookTargets">look targets in the same direction</param>
    /// <param name="distance">look distance</param>
    public void SetTarget(List<Transform> lookTargets ,float distance) {
        target = CalculateCenter(lookTargets);
        Vector3 cameraEndPosition = Vector3.zero;
        Vector3 dir = Vector3.Normalize(camera.transform.position-target);
        cameraEndPosition = target + dir * Mathf.Clamp(distance,minDistance,maxDistance);

        StartCoroutine(CameraToEndPosition(target, cameraEndPosition));
    }

    IEnumerator CameraToEndPosition(Vector3 target,Vector3 endPosition,float delataTime=1.0f) {
        float timer = 0.0f;
        while (timer < delataTime) {
            timer += Time.deltaTime;
            camera.transform.LookAt(target);
            camera.transform.position = Vector3.Lerp(camera.transform.position,endPosition,timer/delataTime);
            yield return null;
        }
        mouseHorAngle = camera.transform.eulerAngles.y;
        mouseVerAngle = camera.transform.eulerAngles.x;
        distance = Vector3.Distance(camera.transform.position,targetObject.transform.position);
    }

    private void LateUpdate()
    {
        if (Input.GetMouseButton(1)|| Input.GetAxis("Mouse ScrollWheel")!=0)
        {
            
            mouseHorAngle += Input.GetAxis("Mouse X") * angleDamp;
            mouseVerAngle -= Input.GetAxis("Mouse Y") * angleDamp;

            mouseVerAngle = ClampAngle(mouseVerAngle, downAngle, upAngle);
            mouseHorAngle = ClampAngle(mouseHorAngle,leftAngle,rightAngle);

            distance -= Input.GetAxis("Mouse ScrollWheel") * distanceDamp;
            distance = Mathf.Clamp(distance, minDistance, maxDistance);
            Quaternion rotation = Quaternion.Euler(mouseVerAngle, mouseHorAngle, 0.0f);
            Vector3 disVector = new Vector3(0.0f, 0.0f,distance);
            Vector3 position = -(rotation * disVector)+targetObject.transform.position;

            //adjust the camera
            if (needDamping)
            {
                camera.transform.rotation = Quaternion.Lerp(camera.transform.rotation, rotation, Time.deltaTime * angleDamp);
                camera.transform.position = Vector3.Lerp(camera.transform.position, position, Time.deltaTime * distanceDamp);
            }
            else
            {
                camera.transform.rotation = rotation;
                camera.transform.position = position;
            }

        }

        Debug.DrawLine(targetObject.transform.position, camera.transform.position, Color.blue, 10.0f);
    }


    static float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360)
            angle += 360;
        if (angle > 360)
            angle -= 360;
        return Mathf.Clamp(angle, min, max);
    }
}