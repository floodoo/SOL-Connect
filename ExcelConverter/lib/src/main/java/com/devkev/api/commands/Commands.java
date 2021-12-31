package com.devkev.api.commands;

import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Color;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.devkev.devscript.raw.Block;
import com.devkev.devscript.raw.Command;
import com.devkev.devscript.raw.Library;
import com.devkev.devscript.raw.Process;
import com.devkev.main.Connection;

public class Commands extends Library {

	public static final int MAX_CELL_ENTRIES = 200;
	
	public Commands() {
		super("Commands");
	}

	@Override
	public Command[] createLib() {
		return new Command[] {
			
			new Command("getphasierung", "string", "getCurrentPhasierung <woche>") {
				@Override
				public Object execute(Object[] arg0, Process arg1, Block arg2) throws Exception {
					//Vielleicht?
					return null;
				}
			},
			
			new Command("convertxssf", "", "Erwartet einen Stream") {
				@Override
				public Object execute(Object[] arg0, Process arg1, Block arg2) throws Exception {
					
					Connection c = (Connection) arg1.getVariable("connection", arg1.getMain());
					
					//Warte auf den Excel stram. Der timeout wird vom observer gehandled
					//Sende ready antwort. Dies signalisiert dass der Server bereit ist die Excel zu empfangen!
					BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(c.client.getOutputStream()));
					writer.write("ready\r\n");
					writer.flush();
					
					
					try {
						
						StringBuilder json = new StringBuilder("{\"message\": \"ok\", \"cells\":[");
			            Workbook workbook = new XSSFWorkbook(c.client.getInputStream());
			    		Sheet sheet = workbook.getSheetAt(0);
			    		
			    		Map<Integer, List<String>> data = new HashMap<>();
			    		int i = 0;
			    		int cellEntries = 0;
			    		
			    		main: for (Row row : sheet) {
			    			
			    		    data.put(i, new ArrayList<String>());
			    		    for (Cell cell : row) {
			    		    	
			    		    	Color fillColor = cell.getCellStyle().getFillForegroundColorColor();
			    		    	if(fillColor != null) {
				    		    	String hex = ((XSSFColor) fillColor).getARGBHex().substring(1);
				    		    	
				    		    	String cellEntry = "{\"x\": " + cell.getColumnIndex() + ",\"y\":" + cell.getRowIndex() + ",";
				    		    	
				    		    	String colorEntry = "\"c\": {";
				    		    	
				    		    	int colorIndex = 0;
				    		    	for(int rgb : hex2Rgb(hex)) {
				    		    		if(colorIndex == 0) colorEntry += "\"r\": " + rgb + ",";
				    		    		else if(colorIndex == 1) colorEntry += "\"g\": " + rgb + ",";
				    		    		else if(colorIndex == 2) colorEntry += "\"b\": " + rgb;
				    		    		
				    		    		colorIndex++;
				    		    	}
				    		    	colorEntry += "}";
				    		    	
				    		    	cellEntry += colorEntry + "},";
				    		    	json.append(cellEntry);
				    		    	cellEntries++;
				    		    	
				    		    	if(cellEntries > MAX_CELL_ENTRIES) {
				    		    		System.out.println("Exceeded max colored cell entries. Aborting");
				    		    		break main;
				    		    	}
			    		    	}
			    		    }
			    		    i++;
			    		}
			    		
			    		if(i > 0) json.deleteCharAt(json.length()-1);
			    		json.append("]}");
			    		
			    		System.out.println("Sending response");
			    		writer.write(json.toString() + "\r\n");
			    		writer.flush();
			    		workbook.close();
			    		
					} catch(Exception e) {
						
						System.err.println("Error while converting Excel: " + e.getMessage());
						writer.write("{\"message\": \"" + e.getMessage() + "\"}");
			    		writer.flush();
					}
					return null;
				}
				
				public int[] hex2Rgb(String colorStr) {
				    return new int[] {
				            Integer.valueOf(colorStr.substring(1, 3), 16 ),
				            Integer.valueOf(colorStr.substring(3, 5), 16 ),
				            Integer.valueOf(colorStr.substring(5, 7), 16 )
				    };
				}
			}
		};
	}
}
