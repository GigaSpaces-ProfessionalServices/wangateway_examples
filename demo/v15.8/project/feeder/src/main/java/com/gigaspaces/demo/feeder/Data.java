package com.gigaspaces.demo.feeder;

import com.gigaspaces.annotation.pojo.SpaceClass;
import com.gigaspaces.annotation.pojo.SpaceId;
import com.gigaspaces.annotation.pojo.SpaceStorageType;
import com.gigaspaces.metadata.StorageType;

import java.util.Objects;


@SpaceClass
public class Data implements java.io.Serializable {

    private static final long serialVersionUID = 0L;

    private Integer id;
    private String message;
    private Object value;
    private Boolean processed;

    @SpaceId(autoGenerate = false)
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @SpaceStorageType(storageType = StorageType.BINARY)
    public Object getValue() {
        return value;
    }

    public void setValue(Object value) {
        this.value = value;
    }

    public Boolean getProcessed() {
        return processed;
    }

    public void setProcessed(Boolean processed) {
        this.processed = processed;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Data)) return false;
        Data data = (Data) o;
        return Objects.equals(getId(), data.getId()) &&
                Objects.equals(getMessage(), data.getMessage()) &&
                Objects.equals(getProcessed(), data.getProcessed());
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((id == null) ? 0 : id.hashCode());
        result = prime * result + ((message == null) ? 0 : message.hashCode());
        result = prime * result
                + ((processed == null) ? 0 : processed.hashCode());
        return result;
    }

    @Override
    public String toString() {
        return "Data{" +
                "id=" + id +
                ", message='" + message + '\'' +
                ", processed=" + processed +
                '}';
    }
}


