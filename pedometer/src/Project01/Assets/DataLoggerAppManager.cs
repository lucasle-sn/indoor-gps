/*
 * MCEN90032 Sensor Systems.
 * Advanced example of how to use the DataLogger GameObject.
 * Allows input of the filename in runtime.
 * Allows the creation of multiple log files.
 * Added sensor readings and time management
 * 
 * Author: Ricardo Garcia-Rosas
 */
using System.Collections;
using UnityEngine;

/// <summary>
/// Advanced example of how to use the DataLogger GameObject.
/// Allows input of the filename in runtime.
/// Allows the creation of multiple log files.
/// Added sensor readings and time management
/// </summary>
public class DataLoggerAppManager : MonoBehaviour
{
    [Tooltip("The DataLogger GameObject to be used for data logging purposes.")]
    public DataLogger dataLogger;
    public GameObject recordingText;
    public GameObject readyText;
    public GameObject createdText;

    // Manages toggling the log on and off
    private bool logEnabled = false;
    // Stores the filename as given in the prompt box
    private string filename = "test1";
    // Stores the start time of all recordings
    private bool setStartTime = false;
    private float startTime = 0.0f;


    // Sensored variables
    private double xAcc, yAcc, zAcc;
    private double xGyr, yGyr, zGyr;
    private double xMag, yMag, zMag;
    private double xAcc_linear, yAcc_linear, zAcc_linear;
    private static double xAcc_calib = 0;
    private static double yAcc_calib = 0;
    private static double zAcc_calib = 0;
    private const double LP_FILTER_COEFF = 0.13;



    // FixedUpdate is called every "fixedDeltaTime" as given by the physics engine.
    // This is a deterministic function, which means that it occurs at specified intervals.
    // It is very useful when you want to perform operations that are time sensitive!
    void FixedUpdate()
    {
        // Set the start time here otherwise it'll use framerate times
        if (setStartTime)
        {
            startTime = Time.time;
            setStartTime = false;
        }

        // Check that the log is enabled and the logger is valid.
        if (logEnabled && dataLogger != null)
        {
            // Get sensor data
            xAcc = Input.acceleration.x;
            yAcc = Input.acceleration.y;
            zAcc = Input.acceleration.z;

            xGyr = Input.gyro.rotationRate.x;
            yGyr = Input.gyro.rotationRate.y;
            zGyr = Input.gyro.rotationRate.z;

            xMag = Input.compass.rawVector.x;
            yMag = Input.compass.rawVector.y;
            zMag = Input.compass.rawVector.z;


            // Get filtered data - Low pass filter
            xAcc_calib = (1 - LP_FILTER_COEFF) * xAcc_calib + LP_FILTER_COEFF * xAcc;
            yAcc_calib = (1 - LP_FILTER_COEFF) * yAcc_calib + LP_FILTER_COEFF * yAcc;
            zAcc_calib = (1 - LP_FILTER_COEFF) * zAcc_calib + LP_FILTER_COEFF * zAcc;

            xAcc_linear = xAcc - xAcc_calib;
            yAcc_linear = yAcc - yAcc_calib;
            zAcc_linear = zAcc - zAcc_calib;


            // Log the time and sensor data
            string data = (Time.time - startTime).ToString();
            data += "," + xAcc + "," + yAcc + "," + zAcc;
            data += "," + xGyr + "," + yGyr + "," + zGyr;
            data += "," + xMag + "," + yMag + "," + zMag;
            data += "," + xAcc_calib + "," + yAcc_calib + "," + zAcc_calib;
            data += "," + xAcc_linear + "," + yAcc_linear + "," + zAcc_linear;

            //data += "," + Input.acceleration.x + "," + Input.acceleration.y + "," + Input.acceleration.z;
            //data += "," + Input.gyro.rotationRate.x + "," + Input.gyro.rotationRate.y + "," + Input.gyro.rotationRate.z;
            //data += "," + input.compass.rawvector.x + "," + input.compass.rawvector.y + "," + input.compass.rawvector.z;


            dataLogger.AppendData(data);
        }
    }

    /// <summary>
    /// Updates the filename with the given name.
    /// Automatically assigns .csv extension.
    /// </summary>
    /// <param name="filename">The filename without extension</param>
    public void UpdateFileName(string filename)
    {
        if (filename == string.Empty)
            throw new System.ArgumentNullException("The filename is invalid");

        // Add extension and set logger filename
        filename += ".csv";
        dataLogger.fileName = filename;
    }

    /// <summary>
    /// Creates a new log file with the current filename.
    /// Automatically closes existing logs.
    /// </summary>
    public void CreateNewLog()
    {
        // Close existing log file
        dataLogger.CloseLog();

        // Create the new log
        dataLogger.InitialiseLogger();

        // Show the prompt
        StartCoroutine(DisplayCreatedPrompt());
    }

    /// <summary>
    /// Displays the "log created" message for 2 seconds.
    /// </summary>
    /// <returns>Yield instruction.</returns>
    private IEnumerator DisplayCreatedPrompt()
    {
        readyText.SetActive(false);
        createdText.SetActive(true);
        yield return new WaitForSecondsRealtime(2.0f);
        readyText.SetActive(true);
        createdText.SetActive(false);
    }

    /// <summary>
    /// Enables or disables the sensors.
    /// </summary>
    /// <param name="enable">Bool to enable/disable sensors.</param>
    public void SetSensorsEnable(bool enable)
    {
        // Enable gyro and compass
        Input.gyro.enabled = enable;
        Input.compass.enabled = enable;
    }

    // Starts the data logging process.
    public void StartDataLogging()
    {
        if (!logEnabled)
            // Enable sensors
            SetSensorsEnable(true);

        // Enable logging
        logEnabled = true;
        // Update the status UI
        recordingText.SetActive(true);
        readyText.SetActive(false);

        // Enable starttime flag
        setStartTime = true;
    }

    // Handles stopping the data log.
    public void StopDataLogging()
    {
        if (logEnabled)
            StartCoroutine(StopLogging());
    }

    /// <summary>
    /// Coroutine to stop the data logger.
    /// Waits for the next FixedUpdate so the log is first disabled
    /// and then the file is closed.
    /// This avoids the file being closed while attempting to append data.
    /// Check Unity's documentation and tutorials for more information on Coroutines.
    /// </summary>
    /// <returns></returns>
    private IEnumerator StopLogging()
    {
        // Disable sensors
        SetSensorsEnable(false);
        logEnabled = false;
        // Wait for deltaTime seconds
        yield return new WaitForFixedUpdate();
        // Save log
        dataLogger.SaveLog();

        // Update the status UI
        recordingText.SetActive(false);
        readyText.SetActive(true);
    }

    // Saves the log and closes the app
    public void CloseApp()
    {
        StartCoroutine(StopApplication());
    }

    /// <summary>
    /// Coroutine to save the log and stop the application.
    /// Makes sure that enough time is given to do all closing procedures.
    /// </summary>
    private IEnumerator StopApplication()
    {
        // Stop and save the log
        StopDataLogging();
        // Wait one second
        yield return new WaitForSeconds(1.0f);

        // Quit application (automatically closes log)
        #if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
        #else
                    Application.Quit();
        #endif
    }
}
