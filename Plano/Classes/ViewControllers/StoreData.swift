import UIKit


class StoreData{
    var orderUUID:String!
    var productName:String!
    var purchaseDate:String!
    var deliveryStatus:String!
    var checkOutValue:String!
    var billingAddress:String!
    var billingPostcde:String!
    var quizUrl:String!
    var contactCountryCode:String!
    var contactNumber:String!
    var shippingAddress:String!
    var shippingPostcode:String!
    var productImage:String!
    var price:String!
    var productID:String!
    var merchantName:String!
    
    public func getProductID()->String{
        return self.productID
    }
    public func setProductID(productID:String){
        self.productID=productID
    }
    
    public func getPrice()->String{
        return self.price
    }
    public func setPrice(price:String){
        self.price=price
    }
    
    public func getProductImage()->String{
        return self.productImage
    }
    public func setProductImage(productImage:String){
        self.productImage=productImage
    }
    
    public func getBillingAddress()->String{
        return self.billingAddress
    }
    public func setBillingAddress(billingAddress:String){
        self.billingAddress=billingAddress
    }
    public func getQuiz()->String{
        return self.quizUrl
    }
    public func setQuiz(QuizUrls:String){
        self.quizUrl=QuizUrls
    }
    public func getBillingPostcde()->String{
        return self.billingPostcde
    }
    public func setBillingPostcde(billingPostcde:String){
        self.billingPostcde=billingPostcde
    }
    
    public func getContactCountryCode()->String{
        return self.contactCountryCode
    }
    public func setContactCountryCode(contactCountryCode:String){
        self.contactCountryCode=contactCountryCode
    }
    
    public func getContactNumber()->String{
        return self.contactNumber
    }
    public func setContactNumber(contactNumber:String){
        self.contactNumber=contactNumber
    }
    
    public func getShippingAddress()->String{
        return self.shippingAddress
    }
    public func setShippingAddress(shippingAddress:String){
        self.shippingAddress=shippingAddress
    }
    
    public func getShippingPostcode()->String{
        return self.shippingPostcode
    }
    public func setShippingPostcode(shippingPostcode:String){
        self.shippingPostcode=shippingPostcode
    }
    
    public func getCheckOutValue()->String{
        return self.checkOutValue
    }
    public func setCheckOutValue(checkOutValue:String){
        self.checkOutValue=checkOutValue
    }
    
    public func getOrderUUID()->String{
        return self.orderUUID
    }
    public func setOrderUUID(orderUUID:String){
        self.orderUUID=orderUUID
    }
    
    public func getProductName()->String{
        return self.productName
    }
    public func setProductName(productName:String){
        self.productName=productName
    }
    
    public func getMerchantName()->String{
        return self.merchantName
    }
    public func setMerchantName(merchantName:String){
        self.merchantName=merchantName
    }
    
    public func getPurchaseDate()->String{
        return self.purchaseDate
    }
    public func setPurchaseDate(purchaseDate:String){
        self.purchaseDate=purchaseDate
    }
    
    public func getDeliveryStatus()->String{
        return self.deliveryStatus
    }
    public func setDeliveryStatus(deliveryStatus:String){
        self.deliveryStatus=deliveryStatus
    }
}
