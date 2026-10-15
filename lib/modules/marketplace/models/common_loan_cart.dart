import 'package:peerbridge/modules/marketplace/models/primary_market_loan.dart';
import 'package:peerbridge/modules/marketplace/models/secondary_market_loan.dart';

class CommonLoanCart {
  String productName;
  double loanAmount;
  String contract;
  String category;
  bool alreadyFunded;
  String investorId;
  double alreadyCommitedAmount;

  bool isSecondary;
  String frequency;
  double tenor;
  double lenderXIRR;

  bool isAddedToCart;
  double fundedAmount;
  String customerName;

  CommonLoanCart(
      {this.productName = "",
      this.loanAmount = 0,
      this.investorId = "",
      this.contract = "",
      this.lenderXIRR = 0,
      this.tenor = 0,
      this.category = "",
      this.alreadyFunded = false,
      this.alreadyCommitedAmount = 0,
      this.isAddedToCart = false,
      this.fundedAmount = 1000,
      this.frequency = "",
      this.isSecondary = false,
      this.customerName = ''});

  double getAlreadyFunded() {
    var amount = 0.0;

    amount = (alreadyCommitedAmount / loanAmount) * 100;

    return amount;
  }

  factory CommonLoanCart.fromPrimaryMarketLoan(PrimaryMarketLoan data) {
    return CommonLoanCart(
      alreadyCommitedAmount: data.alreadyCommitedAmount,
      alreadyFunded: data.isMaxFunded(),
      isAddedToCart: data.isAddedToCart,
      category: data.category,
      lenderXIRR: data.lenderXIRR,
      tenor: data.tenor,
      contract: data.contract,
      frequency: data.frequency,
      fundedAmount: data.fundedAmount,
      loanAmount: data.loanAmount,
      productName: data.productName,
      customerName: data.customerName,
    );
  }

  factory CommonLoanCart.fromSecondaryMarketLoan(SecondaryMarketLoan data) {
    return CommonLoanCart(
      alreadyFunded: data.alreadyFunded,
      isAddedToCart: data.isAddedToCart,
      investorId: data.investorId,
      isSecondary: true,
      category: data.status,
      contract: data.contract,
      lenderXIRR: data.interestRate,
      tenor: data.tenorRemaining.toDouble(),
      frequency: data.frequency,
      fundedAmount: data.sellingPrice.toDouble(),
      loanAmount: data.sellingPrice,
      customerName: data.customerName,
    );
  }

  @override
  String toString() {
    return (isSecondary) ? investorId : contract;
  }

  @override
  bool operator ==(Object other) {
    return this.toString() == other.toString();
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
