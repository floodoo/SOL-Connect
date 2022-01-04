package com.devkev.main;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Logger {
	
	public File logFile;
	public BufferedReader fileReader;
	public BufferedWriter fileWriter;
	
	private static final DateFormat format = new SimpleDateFormat("dd.MM.yyyy-HH:mm:ss");
	
	Logger() {
		logFile = new File("instancelog.log");
		try {
			logFile.createNewFile();
			fileReader = new BufferedReader(new FileReader(logFile));
			fileWriter = new BufferedWriter(new FileWriter(logFile));
			
			fileWriter.write("Instance startet at " + format.format(new Date(System.currentTimeMillis())) + "\n\n");
			fileWriter.flush();
			
			System.out.println("Logfile created at " + logFile.getAbsolutePath() + "\n");
		} catch (IOException e) {
			System.err.println("Failed to create log file using default console log.");
			e.printStackTrace();
			logFile = null;
			fileWriter = null;
			fileReader = null;
		}
	}
	
	public void logError(String message) {
		if(fileWriter == null) {
			System.err.println("ERROR [" + format.format(new Date(System.currentTimeMillis())) + "] " + message);
		} else {
			try {
				fileWriter.append("ERROR [" + format.format(new Date(System.currentTimeMillis())) + "] " + message + "\n");
				fileWriter.flush();
			} catch (IOException e) {
				System.err.println("ERROR [" + format.format(new Date(System.currentTimeMillis())) + "] " + message);
			}
		}
	}
	
	public void log(String message) {
		if(fileWriter == null) {
			System.out.println("INFO [" + format.format(new Date(System.currentTimeMillis())) + "] " + message);
		} else {
			try {
				fileWriter.append("INFO [" + format.format(new Date(System.currentTimeMillis())) + "] " + message.replace("\n", "") + "\n");
				fileWriter.flush();
			} catch (IOException e) {
				System.out.println("INFO [" + format.format(new Date(System.currentTimeMillis())) + "] " + message);
			}
		}
	}
}
