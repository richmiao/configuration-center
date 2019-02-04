package main

import (
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"fmt"
	// "sort"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
	// "github.com/hyperledger/fabric/protos/utils"
)

// SmartContract Define the Smart Contract structure
type SmartContract struct {
}



// History Struct
type History struct {
	TxID      string `json:"txid"`
	Value     string `json:"value"`
	Timestamp int64  `json:"txTimeStamp"`
	IsDelete  bool   `json:"isDeleted"`
}

// Init method of the chaincode
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	fmt.Println("Init chaincode")
	return shim.Success(nil)
}

// Invoke if chaincode
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()
	fmt.Println("Function: ", function, ", Args: ", args)
	if function == "query" {
		// do mongoquery
		// if hasPermission(APIstub, "query") != true {
		// 	fmt.Println("!!!PERMISSION DENIED!!!")
		// 	return shim.Error("permission denied (required permission: query)")
		// }
		return query(APIstub, args)

	} else if function == "getHistory" {
		// if hasPermission(APIstub, "getHistory") != true {
		// 	fmt.Println("!!!PERMISSION DENIED!!!")
		// 	return shim.Error("permission denied (required permission: getHistory)")
		// }
		return getHistory(APIstub, args)

	}
	return edit(APIstub, function, args)
}

func getHistory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	resultSet := []History{}
	if len(args) != 1 {
		return shim.Error("missing parameter")
	}
	keyModification, err1 := APIstub.GetHistoryForKey("Asset_" + args[0])
	if catchErr(err1) {
		return shim.Error("Get history for " + args[0] + " failed")
	}
	for keyModification.HasNext() {
		his, err2 := keyModification.Next()
		if catchErr(err2) {
			continue
		}
		history := History{}
		history.TxID = his.GetTxId()
		history.Value = string(his.GetValue())
		history.Timestamp = his.GetTimestamp().GetSeconds() * 1000
		history.IsDelete = his.GetIsDelete()
		resultSet = append(resultSet, history)
	}
	data, err3 := json.Marshal(resultSet)
	if catchErr(err3) {
		return shim.Error("Cannot marcshal data")
	}
	return shim.Success(data)
}

func insert(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
		var param map[string]interface{}
		err := json.Unmarshal([]byte(args[0]), &param)
		if err == nil {
			return shim.Error("need JSON argument");
		}

    if(param["userId"] == nil){
			return shim.Error("missing userId");
		}
    if(param["data"] == nil){
			return shim.Error("missing data");
		}
    if(param["intend"] == nil){
			return shim.Error("missing intend");
		}

		//todo: test datatypes
		var intend string;
		intend = param["intend"].(string)
		if len(intend) < 1 {
      return shim.Error("missing intend")
		}
		var data map[string]interface{};
		data = param["data"].(map[string]interface{});

		var id = data["_id"].(string);
    
    // untested
    existingData, err2 := APIstub.GetState(id)
		if err2 != nil {
			fmt.Println(err2)
			return shim.Error("can't read the state")
		}
    if existingData != nil {
      return shim.Error("already exists")
    }

    // Write the states back to the ledger
    APIstub.PutState(id, param["data"].([]byte))

		return shim.Success([]byte("true"));
}


func query(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 1 {
		return shim.Error("missing parameter")
	}

	iterator, err1 := APIstub.GetQueryResult(args[0])
	if catchErr(err1) {
		return shim.Error("can't query that")
	}
	data, err2 := dataFromIterator(iterator)
	if catchErr(err2) {
		return shim.Error("loading assets failed")
	}
	return shim.Success([]byte(data))
}

func keyQuery(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 1 {
		return shim.Error("missing parameter")
	}

	byteData, _ := APIstub.GetState(args[0])
	return shim.Success(byteData)
}

func edit(APIstub shim.ChaincodeStubInterface, function string, args []string) sc.Response {
	// if len(args) != 1 {
	// 	return shim.Error("missing parameter")
	// }
	// incommingAsset := Asset{}
	// err1 := json.Unmarshal([]byte(args[0]), &incommingAsset)
	// if catchErr(err1) {
	// 	return shim.Error("invalid parameter")
	// }
	// incommingAsset.LastUpdateReason = function
	// creatorCert, err7 := parseCreator(APIstub)
	// if catchErr(err7) {
	// 	return shim.Error(err7.Error())
	// }
	// incommingAsset.LastUpdateUsername = creatorCert.Subject.CommonName
	// incommingAsset.LastUpdateUserOrg = creatorCert.Issuer.Organization
	// data, err2 := APIstub.GetState("Asset_" + incommingAsset.ID)
	// if catchErr(err2) {
	// 	return shim.Error("error when reading asset")
	// }
	// timestamp, err4 := APIstub.GetTxTimestamp()
	// if catchErr(err4) {
	// 	return shim.Error("can not read time")
	// }
	// if len(data) == 0 {
	// 	if hasPermission(APIstub, "create") != true {
	// 		return shim.Error("permission denied (required permission: create)")
	// 	}

	// 	incommingAsset.CreateTime = timestamp.Seconds * 1000
	// 	incommingAsset.UpdateTime = incommingAsset.CreateTime
	// 	createData, err3 := json.Marshal(incommingAsset)
	// 	if catchErr(err3) {
	// 		return shim.Error(err3.Error())
	// 	}
	// 	APIstub.PutState("Asset_"+incommingAsset.ID, createData)
	// } else {
	// 	if hasPermission(APIstub, "update") != true {
	// 		return shim.Error("permission denied (required permission: update)")
	// 	}
	// 	existingAsset := Asset{}
	// 	err4 := json.Unmarshal(data, &existingAsset)
	// 	if catchErr(err4) {
	// 		return shim.Error("invalid data in ledger")
	// 	}
	// 	if len(incommingAsset.Category) != 0 {
	// 		existingAsset.Category = incommingAsset.Category
	// 	}
	// 	if len(incommingAsset.SubCategory) != 0 {
	// 		existingAsset.SubCategory = incommingAsset.SubCategory
	// 	}
	// 	if len(incommingAsset.AssetType) != 0 {
	// 		existingAsset.AssetType = incommingAsset.AssetType
	// 	}
	// 	if incommingAsset.Longitude < 360 && incommingAsset.Latitude < 360 && incommingAsset.Longitude > -360 && incommingAsset.Latitude > -360 {
	// 		existingAsset.Longitude = incommingAsset.Longitude
	// 		existingAsset.Latitude = incommingAsset.Latitude
	// 	}
	// 	if len(incommingAsset.MetaData) != 0 {
	// 		existingAsset.MetaData = incommingAsset.MetaData
	// 	}
	// 	if len(incommingAsset.AssetStatus) != 0 {
	// 		existingAsset.AssetStatus = incommingAsset.AssetStatus
	// 	}
	// 	if len(incommingAsset.Contains) != 0 {
	// 		existingAsset.Contains = incommingAsset.Contains
	// 	}
	// 	existingAsset.UpdateTime = timestamp.Seconds * 1000
	// 	existingAsset.LastUpdateReason = incommingAsset.LastUpdateReason
	// 	existingAsset.LastUpdateUsername = incommingAsset.LastUpdateUsername
	// 	existingAsset.LastUpdateUserOrg = incommingAsset.LastUpdateUserOrg
	// 	updateData, err6 := json.Marshal(existingAsset)
	// 	if catchErr(err6) {
	// 		return shim.Error("json marshal failed")
	// 	}
	// 	APIstub.PutState("Asset_"+existingAsset.ID, updateData)
	// }

	return shim.Success([]byte("true"))
}



// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {
	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}

func dataFromIterator(resultsIterator shim.StateQueryIteratorInterface) (string, error) {
	var data = "";
	data = data + "["
	for resultsIterator.HasNext() {
		kv, err := resultsIterator.Next()
		if err != nil {
			return data, err
		}
		if len(data) > 1 {
			data = data + ","
		}

		data = data + string(kv.Value)
	}

	data = data + "]";
	return data, nil
}

func catchErr(err error) bool {
	if err != nil {
		fmt.Println(err)
		return true
	}
	return false
}


// ---------------------------------------------------------------------------------------------------------------------
// ------------------------------------- L I B R A R Y -----------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------

func parseCreator(APIstub shim.ChaincodeStubInterface) (*x509.Certificate, error) {
	creatorBytes, _ := APIstub.GetCreator()
	//.split('\n').slice(1,-2).join('\n')
	var b = strings.Split(string(creatorBytes), "\n")
	var b2 = b[2 : len(b)-2]
	var b3 = strings.Join(b2, "")
	var b4, err = base64.StdEncoding.DecodeString(b3)
	if err != nil {
		return new(x509.Certificate), err
	}
	creatorCert, err := x509.ParseCertificate([]byte(b4))
	if err != nil {
		return new(x509.Certificate), err
	}
	return creatorCert, nil
}

// parse the attributes from JSON format in the certificate
func getCreatorsAttributes(creator *x509.Certificate) (map[string]string, error) {
	var data = make(map[string]map[string]string)
	i := 0
	for i < len(creator.Extensions) {
		extention := creator.Extensions[i]
		// fmt.Println("e", extention.Id, string(extention.Value))
		if extention.Id.String() == "1.2.3.4.5.6.7.8.1" {
			err := json.Unmarshal(extention.Value, &data)
			if err != nil {
				return data["attrs"], err
			}
		}
		i = i + 1
	}
	return data["attrs"], nil
}
