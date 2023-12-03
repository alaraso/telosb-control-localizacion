/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'TestSerialMsg'
 * message type.
 */

public class TestSerialMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 9;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 137;

    /** Create a new TestSerialMsg of size 9. */
    public TestSerialMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new TestSerialMsg of the given data_length. */
    public TestSerialMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestSerialMsg with the given data_length
     * and base offset.
     */
    public TestSerialMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestSerialMsg using the given byte array
     * as backing store.
     */
    public TestSerialMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestSerialMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public TestSerialMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestSerialMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public TestSerialMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestSerialMsg embedded in the given message
     * at the given base offset.
     */
    public TestSerialMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestSerialMsg embedded in the given message
     * at the given base offset and length.
     */
    public TestSerialMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <TestSerialMsg> \n";
      try {
        s += "  [tipo=0x"+Long.toHexString(get_tipo())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [nodeid=0x"+Long.toHexString(get_nodeid())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [dato=0x"+Long.toHexString(get_dato())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [humedad=0x"+Long.toHexString(get_humedad())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [cord_x=0x"+Long.toHexString(get_cord_x())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [cord_y=0x"+Long.toHexString(get_cord_y())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: tipo
    //   Field type: short, signed
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'tipo' is signed (true).
     */
    public static boolean isSigned_tipo() {
        return true;
    }

    /**
     * Return whether the field 'tipo' is an array (false).
     */
    public static boolean isArray_tipo() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'tipo'
     */
    public static int offset_tipo() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'tipo'
     */
    public static int offsetBits_tipo() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'tipo'
     */
    public short get_tipo() {
        return (short)getUIntBEElement(offsetBits_tipo(), 8);
    }

    /**
     * Set the value of the field 'tipo'
     */
    public void set_tipo(short value) {
        setUIntBEElement(offsetBits_tipo(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'tipo'
     */
    public static int size_tipo() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'tipo'
     */
    public static int sizeBits_tipo() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: nodeid
    //   Field type: int, signed
    //   Offset (bits): 8
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'nodeid' is signed (true).
     */
    public static boolean isSigned_nodeid() {
        return true;
    }

    /**
     * Return whether the field 'nodeid' is an array (false).
     */
    public static boolean isArray_nodeid() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'nodeid'
     */
    public static int offset_nodeid() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'nodeid'
     */
    public static int offsetBits_nodeid() {
        return 8;
    }

    /**
     * Return the value (as a int) of the field 'nodeid'
     */
    public int get_nodeid() {
        return (int)getUIntBEElement(offsetBits_nodeid(), 16);
    }

    /**
     * Set the value of the field 'nodeid'
     */
    public void set_nodeid(int value) {
        setUIntBEElement(offsetBits_nodeid(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'nodeid'
     */
    public static int size_nodeid() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'nodeid'
     */
    public static int sizeBits_nodeid() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: dato
    //   Field type: int, signed
    //   Offset (bits): 24
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'dato' is signed (true).
     */
    public static boolean isSigned_dato() {
        return true;
    }

    /**
     * Return whether the field 'dato' is an array (false).
     */
    public static boolean isArray_dato() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'dato'
     */
    public static int offset_dato() {
        return (24 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'dato'
     */
    public static int offsetBits_dato() {
        return 24;
    }

    /**
     * Return the value (as a int) of the field 'dato'
     */
    public int get_dato() {
        return (int)getUIntBEElement(offsetBits_dato(), 16);
    }

    /**
     * Set the value of the field 'dato'
     */
    public void set_dato(int value) {
        setUIntBEElement(offsetBits_dato(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'dato'
     */
    public static int size_dato() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'dato'
     */
    public static int sizeBits_dato() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: humedad
    //   Field type: int, signed
    //   Offset (bits): 40
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'humedad' is signed (true).
     */
    public static boolean isSigned_humedad() {
        return true;
    }

    /**
     * Return whether the field 'humedad' is an array (false).
     */
    public static boolean isArray_humedad() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'humedad'
     */
    public static int offset_humedad() {
        return (40 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'humedad'
     */
    public static int offsetBits_humedad() {
        return 40;
    }

    /**
     * Return the value (as a int) of the field 'humedad'
     */
    public int get_humedad() {
        return (int)getUIntBEElement(offsetBits_humedad(), 16);
    }

    /**
     * Set the value of the field 'humedad'
     */
    public void set_humedad(int value) {
        setUIntBEElement(offsetBits_humedad(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'humedad'
     */
    public static int size_humedad() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'humedad'
     */
    public static int sizeBits_humedad() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: cord_x
    //   Field type: byte, signed
    //   Offset (bits): 56
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'cord_x' is signed (true).
     */
    public static boolean isSigned_cord_x() {
        return true;
    }

    /**
     * Return whether the field 'cord_x' is an array (false).
     */
    public static boolean isArray_cord_x() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'cord_x'
     */
    public static int offset_cord_x() {
        return (56 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'cord_x'
     */
    public static int offsetBits_cord_x() {
        return 56;
    }

    /**
     * Return the value (as a byte) of the field 'cord_x'
     */
    public byte get_cord_x() {
        return (byte)getSIntBEElement(offsetBits_cord_x(), 8);
    }

    /**
     * Set the value of the field 'cord_x'
     */
    public void set_cord_x(byte value) {
        setSIntBEElement(offsetBits_cord_x(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'cord_x'
     */
    public static int size_cord_x() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'cord_x'
     */
    public static int sizeBits_cord_x() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: cord_y
    //   Field type: byte, signed
    //   Offset (bits): 64
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'cord_y' is signed (true).
     */
    public static boolean isSigned_cord_y() {
        return true;
    }

    /**
     * Return whether the field 'cord_y' is an array (false).
     */
    public static boolean isArray_cord_y() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'cord_y'
     */
    public static int offset_cord_y() {
        return (64 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'cord_y'
     */
    public static int offsetBits_cord_y() {
        return 64;
    }

    /**
     * Return the value (as a byte) of the field 'cord_y'
     */
    public byte get_cord_y() {
        return (byte)getSIntBEElement(offsetBits_cord_y(), 8);
    }

    /**
     * Set the value of the field 'cord_y'
     */
    public void set_cord_y(byte value) {
        setSIntBEElement(offsetBits_cord_y(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'cord_y'
     */
    public static int size_cord_y() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'cord_y'
     */
    public static int sizeBits_cord_y() {
        return 8;
    }

}
