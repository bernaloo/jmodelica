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
package org.jmodelica.ide.outline;

import java.util.ArrayList;

import org.jastadd.plugin.ui.view.JastAddContentProvider;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class InstanceOutlineContentProvider extends JastAddContentProvider {

	@Override
	public Object[] getElements(Object element) {

		if (!(element instanceof StoredDefinition)) {
		    return super.getElements(element);
		}
		
		try {
			StoredDefinition def = 
			    (StoredDefinition) element;
			
			ArrayList<InstClassDecl> instClasses = 
			    ((SourceRoot)def.root())
			    .getProgram()
			    .getInstProgramRoot()
			    .instClassDecls();

			ArrayList<ClassDecl> classes = 
			    def.getElements().<ClassDecl>toArrayList(); 
			
			ArrayList<InstClassDecl> result = 
			    new ArrayList<InstClassDecl>();
			
			for (InstClassDecl inst : instClasses) {
				if (classes.contains(inst.getClassDecl()))
					result.add(inst);
			}
			
			return result.toArray();
			
		} catch (Exception e) {
		    e.printStackTrace();
			return 
			    new Object[0];
		}

	}

	@Override
	public Object getParent(Object element) {
	    
	    boolean parentIsInstRoot =
	        super.getParent(element) instanceof InstProgramRoot;
	    
	    if (parentIsInstRoot)
    		return
    		    ((InstClassDecl) element)
    		    .getClassDecl()
    		    .getParent();
	    
	    return super.getParent(element);
	
	}

}
