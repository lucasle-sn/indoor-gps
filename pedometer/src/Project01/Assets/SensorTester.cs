/*
 * Basic smartphone sensor testing for MCEN90032 Sensor Systems.
 * 
 * Author: Ricardo Garcia-Rosas
 */
using UnityEngine;

public class SensorTester : MonoBehaviour
{
    public string studentID = "";
    [Tooltip("Enable to skip system check and force sensor reading. Useful when using Remote mode.")]
    public bool remoteMode = false;
    public GUIStyle guiStyle; // Make the GUI styling public so we can edit it in the Unity Editor.
    private bool passedTest = true; // Test flag

    //
    // This Unity Engine function is used to display basic GUI
    //
    void OnGUI()
    {
        // Let's start by printing the subject info :)
        // Create a GUI group and set the font colour
        GUI.BeginGroup(new Rect(Screen.width / 2 - 400, Screen.height / 2 - 600, 2000, 2000));
        guiStyle.normal.textColor = Color.blue;
        GUI.Label(new Rect(0, 0, 1000, 100), "MCEN90032\nSensor Systems\n" + studentID, guiStyle);
        // End the group we started above. This is very important to remember!
        GUI.EndGroup();

        // Create a GUI group and set the font colour
        GUI.BeginGroup(new Rect(Screen.width / 2 - 400, Screen.height / 2 - 300, 2000, 2000));
        guiStyle.normal.textColor = Color.white;

        // Print OS information
        string os_info = SystemInfo.operatingSystem;
        GUI.Label(new Rect(0, 0, 1000, 100), os_info, guiStyle); // Create a GUI label to print the OS data.

        /*
         * Check accelerometer availability and display information.
         */
        string accel_info = "ACCEL: ";
        // Test whether the device has an accelerometer by using the SystemInfo class.
        // If you run this from the editor (remote mode) this check is likely to fail as PCs rarely have these sensors.
        // If you build this and run it on your phone, it should pass without problems.
        if (remoteMode || SystemInfo.supportsAccelerometer == true) 
        {
            accel_info += "OK.\n";
            // Get raw acceleration measurements from the accelerometer using Input.acceleration and save them in a string to display later.
            accel_info += string.Format("x: {0:F4}, y: {1:F4}, z: {2:F4}.", Input.acceleration.x, Input.acceleration.y, Input.acceleration.z);
        }
        else
        {
            // Sensor not supported.
            accel_info += "Failed.";
            passedTest = false;
        }
        // Create a GUI label to display the string containing accelerator information
        GUI.Label(new Rect(0, 120, 1000, 100), accel_info, guiStyle);
        /*
         * END Accelerometer check
         */

        /*
         * Check gyroscope availability and display information.
         * The magnetometer is stored in the same system data as the gyro, so there is only one check for these two sensors.
         */
        // Gyroscope and magnetometer
        string gyro_info = "GYRO: ";
        string comp_info = "MAGN: ";
        // Test whether the device has a gyro (which includes the magnetometer).
        // If you run this from the editor (remote mode) this check is likely to fail as PCs rarely have these sensors.
        // If you build this and run it on your phone, it should pass without problems.
        if (remoteMode || SystemInfo.supportsGyroscope == true)
        {
            // Enable the gyro
            Input.gyro.enabled = true;
            gyro_info += "OK.\n";
            // Get raw angular velocity measurements from the accelerometer using Input.gyro.rotationRate and save them in a string to display later.
            gyro_info += string.Format("x: {0:F4}, y: {1:F4}, z: {2:F4}.", Input.gyro.rotationRate.x, Input.gyro.rotationRate.y, Input.gyro.rotationRate.z);

            // Enable the magnetometer
            Input.compass.enabled = true;
            comp_info += "OK.\n";
            // Get raw magnetic field strength measurements from the magnetometer using Input.compass.rawVector and save them in a string to display later.
            comp_info += string.Format("x: {0:F4}, y: {1:F4}, z: {2:F4}.", Input.compass.rawVector.x, Input.compass.rawVector.y, Input.compass.rawVector.z);
        }
        else
        {
            // Gyro not available
            gyro_info += "Failed.";
            comp_info += "Failed.";
            passedTest = false;
        }
        // Create GUI labels to display the strings containing gyro and magnetometer information.
        GUI.Label(new Rect(0, 240, 1000, 100), gyro_info, guiStyle);
        GUI.Label(new Rect(0, 360, 1000, 100), comp_info, guiStyle);
        /*
         * END Gyro check
         */

        // Test results
        if (passedTest)
        {
            guiStyle.normal.textColor = Color.green;
            GUI.Label(new Rect(0, 480, 1000, 100), "PASSED", guiStyle);
        }
        else
        {
            guiStyle.normal.textColor = Color.red;
            GUI.Label(new Rect(0, 480, 1000, 100), "FAILED", guiStyle);
        }


        // End the group we started above. This is very important to remember!
        GUI.EndGroup();
    }
}
