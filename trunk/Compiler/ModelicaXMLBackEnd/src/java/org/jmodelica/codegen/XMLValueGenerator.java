/*
Copyright (C) 2009 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


package org.jmodelica.codegen;

import java.io.PrintStream;
import java.util.ArrayList;

import org.jmodelica.ast.FBooleanVariable;
import org.jmodelica.ast.FClass;
import org.jmodelica.ast.FIntegerVariable;
import org.jmodelica.ast.FRealVariable;
import org.jmodelica.ast.FStringVariable;
import org.jmodelica.ast.Printer;

/**
 * A generator class for XML code generation which takes a model described by
 * <FClass> and provides an XML document containing the values of the
 * independent parameters in the model. Uses a template for the static general
 * structure of tags and an internal class <TagGenerator> for the parts of the
 * XML that are dynamic, that is, may vary depending on the contents of the
 * underlying model.
 * 
 * @see AbstractGenerator
 * @see TagGenerator
 * 
 */
public class XMLValueGenerator extends GenericGenerator{
	
	/**
	 * Internal class used to generate code for the independent parameter tags.
	 * 
	 * The independent parameters vary from model to model and therefore the 
	 * use of the template file is quite limited. All tags are thus generated 
	 * in this tag class. 
	 * 
	 * @see DAETag
	 */
	class DAETag_XML_parameters extends DAETag {
		
		/**
		 * Constructor.
		 * 
		 * @param myGenerator
		 *            The generator of the tags.
		 * @param fclass
		 *            The FClass object for which the code is generated.
		 */
		public DAETag_XML_parameters(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_parameters","Parameters (choice/optional).",
			  myGenerator,fclass);
		}
	
		/*
		 * (non-Javadoc)
		 * @see org.jmodelica.codegen.AbstractTag#generate(java.io.PrintStream)
		 */
		public void generate(PrintStream genPrinter) {
			TagGenerator tg = new TagGenerator(1);
			ArrayList<FBooleanVariable> booleans = fclass.independentBooleanParameters();
			
			for(FBooleanVariable variable: booleans) {
				genPrinter.print(tg.generateTag("BooleanParameter"));
				genPrinter.print(tg.generateTag("ValueReference")+variable.valueReference()+tg.generateTag("ValueReference"));
				if(variable.hasBindingExp()) {
					genPrinter.print(tg.generateTag("Value")+variable.getBindingExp().ceval().booleanValue()+tg.generateTag("Value"));
				}else{
					genPrinter.print(tg.generateTag("Value")+variable.startAttribute()+tg.generateTag("Value"));
				}
				genPrinter.print(tg.generateTag("BooleanParameter"));
			}
			
			ArrayList<FIntegerVariable> integers = fclass.independentIntegerParameters();
			
			for(FIntegerVariable variable: integers) {
				genPrinter.print(tg.generateTag("IntegerParameter"));
				genPrinter.print(tg.generateTag("ValueReference")+variable.valueReference()+tg.generateTag("ValueReference"));
				if(variable.hasBindingExp()) {
					genPrinter.print(tg.generateTag("Value")+variable.getBindingExp().ceval().intValue()+tg.generateTag("Value"));
				}else{
					genPrinter.print(tg.generateTag("Value")+variable.startAttribute()+tg.generateTag("Value"));
				}
				genPrinter.print(tg.generateTag("IntegerParameter"));

			}
			
			ArrayList<FStringVariable> strings = fclass.independentStringParameters();
			
			for(FStringVariable variable: strings) {
				genPrinter.print(tg.generateTag("StringParameter"));
				genPrinter.print(tg.generateTag("ValueReference")+variable.valueReference()+tg.generateTag("ValueReference"));
				if(variable.hasBindingExp()) {
					genPrinter.print(tg.generateTag("Value")+variable.getBindingExp().ceval().stringValue()+tg.generateTag("Value"));
				}else{
					genPrinter.print(tg.generateTag("Value")+variable.startAttribute()+tg.generateTag("Value"));
				}
				genPrinter.print(tg.generateTag("StringParameter"));

			}
			
			ArrayList<FRealVariable> reals = fclass.independentRealParameters();
			
			for(FRealVariable variable: reals) {
				genPrinter.print(tg.generateTag("RealParameter"));
				genPrinter.print(tg.generateTag("ValueReference")+variable.valueReference()+tg.generateTag("ValueReference"));
				if(variable.hasBindingExp()) {
					genPrinter.print(tg.generateTag("Value")+variable.getBindingExp().ceval().realValue()+tg.generateTag("Value"));
				}else{
					genPrinter.print(tg.generateTag("Value")+variable.startAttribute()+tg.generateTag("Value"));
				}
				genPrinter.print(tg.generateTag("RealParameter"));
			}
		}
	}

	/**
	 * Constructor.
	 * 
	 * @param expPrinter Printer object used to generate code for expressions.
	 * @param escapeCharacter Escape characters used to decode tags.
	 * @param fclass An FClass object used as a basis for the code generation.
	 */
	public XMLValueGenerator(Printer expPrinter, char escapeCharacter, FClass fclass) {
		super(expPrinter, escapeCharacter, fclass);
		
		// Create tags			
		AbstractTag tag = null;
		tag = new DAETag_XML_parameters(this,fclass);
		tagMap.put(tag.getName(), tag);
	}

}
