module salix::lib::Dagre

import salix::Core;
import salix::HTML;
import salix::Node;

import IO;

alias N = void(str, list[value]);
alias E = void(str, str, list[value]);

alias G = void(N, E);

/*

void view() {
  dagre("myGraph", (N n, E e) {
     n("a", () {
       button(onClick(bla()), "Hello");
     });
     
     n("b", ...)
     
     e("a", "b");
     e("b", "c");
  });

}


*/


// rect, circle, ellipse, diamond
Attr shape(str name) = attr("shape", name);
Attr labelStyle(tuple[str,str] styles...) = attr("labelStyle", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ]));
Attr labelStyle(map[str,str] styles) = attr("labelStyle", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ]));
Attr fill(str color) = attr("fill", color); 

Attr arrowheadStyle(tuple[str,str] styles...) = attr("arrowHeadStyle", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ]));
Attr arrowheadStyle(map[str,str] styles) = attr("arrowHeadStyle", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ])); 

//style() is also supported

// https://github.com/d3/d3-3.x-api-reference/blob/master/SVG-Shapes.md#line_interpolate
Attr lineInterpolate(str interp) = attr("lineInterpolate", interp);

Attr arrowheadClass(str class) = attr("arrowheadClass", class);


data GNode = gnode(str id, map[str,str] attrs = (), Node label = txt(""));
data GEdge = gedge(str from, str to, map[str, str] attrs = ());

void dagre(str gid, G g) {
  list[GNode] nodes = [];
  list[GEdge] edges = [];
  
  void n(str id, value vals...) {
    GNode myNode = gnode(id);
    if (vals != []) {
      if (void() labelFunc := vals[-1]) {
        Node label = render(labelFunc);
        myNode.label = label;
      }
      else if (str label := vals[-1]) {
        myNode.label = txt(label);
      }
      myNode.attrs = attrsOf([ a | Attr a <- vals ]);
      nodes += [myNode];
    }
  }
  
  void e(str from, str to, value vals...) {
    GEdge myEdge = gedge(from, to);
    if (vals != []) {
      myEdge.attrs = attrsOf([ a | Attr a <- vals ]);
    }
    edges += [myEdge];
  }
  
  g(n, e);
  
  build([], Node(list[Node] _, list[Attr] _) {
       return native("dagre", gid, (), (), (),
         extra = (
           "nodes": nodes,
           "edges": edges
         ));
    });
  
}
