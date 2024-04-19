package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"

	appv1 "github.com/kkk777-7/grpc-lb-demo/apis/proto/app/v1"

	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
)

type helloServer struct {
	appv1.UnimplementedHelloServiceServer
}

func (s *helloServer) Hello(ctx context.Context, req *appv1.HelloRequest) (*appv1.HelloResponse, error) {
	log.Printf("HelloRequest: %v", req)
	return &appv1.HelloResponse{
		Message: fmt.Sprintf("Hello %s %s", req.Name, req.Age),
	}, nil
}

func NewHelloServer() *helloServer {
	return &helloServer{}
}

func main() {
	port := 50051
	listener, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		panic(err)
	}

	s := grpc.NewServer()

	appv1.RegisterHelloServiceServer(s, NewHelloServer())

	healthSrv := health.NewServer()
	healthpb.RegisterHealthServer(s, healthSrv)
	healthSrv.SetServingStatus("proto.app.v1", healthpb.HealthCheckResponse_SERVING)

	reflection.Register(s)

	go func() {
		log.Printf("start gRPC server port: %v", port)
		s.Serve(listener)
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit
	log.Println("stopping gRPC server...")
	s.GracefulStop()
}
