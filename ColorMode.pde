/**
Enumeration for all the color modes that a IMusicVisualzer could use. Enum.toString returns a string representation
of the mode.
*/
public enum ColorMode {
  RAINBOW_SCALED("Rainbow Scaled"), RAINBOW_SIMPLE("Rainbow Simple"), SIMPLE("Simple Color"), PROGRESSION("Progression");
  
  private final String description; 
  
  private ColorMode(String descrip) {
    this.description = descrip;
  }
  
  @Override
  public String toString() {
      return description;
  }
}