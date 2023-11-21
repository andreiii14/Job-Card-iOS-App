import SwiftUI
import MessageUI

struct ContentView: View {
    @State private var customerName = ""
    @State private var companyName = ""
    @State private var date = ""
    @State private var contactNumber = ""
    @State private var descriptionOfWorks = ""

    @State private var laborHours: [String] = [] // Store labor hours in an array
    @State private var supplierMaterials = [SupplierMaterial]()
    @State private var labourHourlyRate = ""
    @State private var isShowingMailView = false

    var totalMaterialPrice: Double {
        var total = 0.0
        for material in supplierMaterials {
            if let sellPrice = Double(material.sellPrice),
               let buyPrice = Double(material.buyPrice) {
                total += sellPrice - buyPrice
            }
        }
        return total
    }

    var totalOwing: Double {
        let materialPrice = supplierMaterials.reduce(0.0) { result, material in
            if let sellPrice = Double(material.sellPrice) {
                return result + sellPrice
            }
            return result
        }
        let laborCost = (Double(labourHourlyRate) ?? 0) * laborHours.reduce(0.0) { result, hours in
            if let hours = Double(hours) {
                return result + hours
            }
            return result
        }
        return materialPrice + laborCost
    }

    var totalProfit: Double {
        let materialCost = supplierMaterials.reduce(0.0) { result, material in
            if let quantity = Double(material.quantity), let buyPrice = Double(material.buyPrice) {
                return result + (quantity * buyPrice)
            }
            return result
        }
        return totalOwing - materialCost
    }

    var body: some View {
        ScrollView {
            // Section 1 - Customer Information
            VStack(alignment: .leading, spacing: 20) {
                Text("Customer Information")
                    .font(.largeTitle)
                    .padding(.top, 20)
                
                Group {
                    HStack {
                        Text("Customer Name")
                            .font(.headline)
                            .bold()
                        Spacer()
                        TextField("Customer Name", text: $customerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Company Name")
                            .font(.headline)
                            .bold()
                        Spacer()
                        TextField("Company Name", text: $companyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Date")
                            .font(.headline)
                            .bold()
                        Spacer()
                        TextField("Date", text: $date)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Contact Number")
                            .font(.headline)
                            .bold()
                        Spacer()
                        TextField("Contact Number", text: $contactNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Description of Works")
                            .font(.headline)
                            .bold()
                        Spacer()
                        TextField("Description of Works", text: $descriptionOfWorks)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Section 2 - Material Pricing
            VStack(alignment: .leading, spacing: 20) {
                Text("Material Pricing")
                    .font(.largeTitle)
                
                // Rows for supplier materials
                ForEach(supplierMaterials.indices, id: \.self) { index in
                    SupplierMaterialRowView(material: $supplierMaterials[index], supplierMaterials: $supplierMaterials)
                }
                
                // Button to add more rows
                Button(action: {
                    supplierMaterials.append(SupplierMaterial())
                }) {
                    Text("+ Add Row")
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.horizontal)
            
            Divider()
            
            // Section 3 - Labour and Profit
            VStack(alignment: .leading, spacing: 20) {
                Text("Labour and Profit")
                    .font(.largeTitle)
                
                Group {
                    HStack {
                        Text("Labour Hourly Rate") // New input for hourly rate
                            .font(.headline)
                            .bold()
                        Spacer()
                        TextField("Labour Hourly Rate", text: $labourHourlyRate) // Bind to the new state variable
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                    
                    // Button to add more labor hours
                    Button(action: {
                        laborHours.append("") // Add an empty string for a new entry
                    }) {
                        Text("+ Add Hours")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    // Entries for labor hours
                    ForEach(laborHours.indices, id: \.self) { index in
                        HStack {
                            Text("Labour Spent (Hours)")
                                .font(.headline)
                                .bold()
                            Spacer()
                            TextField("Enter Hours", text: $laborHours[index])
                            Spacer()
                            Button(action: {
                                laborHours.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    Divider()
                    
                    // Display Total Owing and Profit
                    Text("Total Owing: \(totalOwing, specifier: "%.2f")")
                        .font(.headline)
                    Text("Profit: \(totalProfit, specifier: "%.2f")")
                        .font(.headline)
                }
            }
            .padding(.horizontal
            )

                        // Submit Button
                        Button(action: {
                            isShowingMailView = true // Show email composition sheet
                        }) {
                            Text("Submit")
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                        .padding()
                    }
                    .sheet(isPresented: $isShowingMailView) {
                        // Use a sheet to present the email composition view
                        EmailComposeView(isShowing: $isShowingMailView, subject: "Job Card", recipients: ["andrei.isak@outlook.com"], messageBody: composeEmailBody())
                    }
                }

                // Function to compose the email body
    func composeEmailBody() -> String {
        var emailBody = "Customer Name: \(customerName)\nCompany Name: \(companyName)\nDate: \(date)\nContact Number: \(contactNumber)\nDescription of Works: \(descriptionOfWorks)"

        emailBody += "\n\nSupplier Materials:\n"
        for material in supplierMaterials {
            emailBody += "Quantity: \(material.quantity), Material Description: \(material.materialDescription), Buy Price: \(material.buyPrice), Is GST Included: \(material.isGSTIncluded), Sell Price including GST: \(material.sellPrice)\n"
        }

        emailBody += "\nLabour Hourly Rate: \(labourHourlyRate)"

        return emailBody
    }

            }

            struct EmailComposeView: View {
                @Binding var isShowing: Bool
                let subject: String
                let recipients: [String]
                let messageBody: String

                var body: some View {
                    NavigationView {
                        if MFMailComposeViewController.canSendMail() {
                            MFMailComposeViewControllerWrapper(
                                isShowing: $isShowing,
                                subject: subject,
                                recipients: recipients,
                                messageBody: messageBody
                            )
                        } else {
                            Text("Email cannot be sent from this device.")
                        }
                    }
                }
            }

            struct MFMailComposeViewControllerWrapper: UIViewControllerRepresentable {
                @Binding var isShowing: Bool
                let subject: String
                let recipients: [String]
                let messageBody: String

                func makeUIViewController(context: UIViewControllerRepresentableContext<MFMailComposeViewControllerWrapper>) -> MFMailComposeViewController {
                    let vc = MFMailComposeViewController()
                    vc.setSubject(subject)
                    vc.setToRecipients(recipients)
                    vc.setMessageBody(messageBody, isHTML: false)
                    vc.mailComposeDelegate = context.coordinator
                    return vc
                }

                func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MFMailComposeViewControllerWrapper>) {}

                func makeCoordinator() -> Coordinator {
                    Coordinator(self)
                }

                class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
                    var parent: MFMailComposeViewControllerWrapper

                    init(_ parent: MFMailComposeViewControllerWrapper) {
                        self.parent = parent
                    }

                    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                        parent.isShowing = false
                    }
                }
            }

            struct ContentView_Previews: PreviewProvider {
                static var previews: some View {
                    ContentView()
                }
            }

            struct SupplierMaterialRowView: View {
                @Binding var material: SupplierMaterial
                @Binding var supplierMaterials: [SupplierMaterial]

                var body: some View {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Supplier / Material Pricing")
                            .font(.title)
                        
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                                .bold()
                            Spacer()
                            TextField("Quantity", text: $material.quantity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("Material Description")
                                .font(.headline)
                                .bold()
                            Spacer()
                            TextField("Material Description", text: $material.materialDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("Buy Price")
                                .font(.headline)
                                .bold()
                            Spacer()
                            TextField("Buy Price", text: $material.buyPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("Sell Price including GST")
                                .font(.headline)
                                .bold()
                            Spacer()
                            TextField("Sell Price including GST", text: $material.sellPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: {
                            // Implement delete action
                            if let index = supplierMaterials.firstIndex(where: { $0.id == material.id }) {
                                supplierMaterials.remove(at: index)
                            }
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                    }
                }
            }

            struct SupplierMaterial: Identifiable {
                let id = UUID()
                var quantity = ""
                var materialDescription = ""
                var buyPrice = ""
                var isGSTIncluded = false
                var sellPrice = ""
            }
